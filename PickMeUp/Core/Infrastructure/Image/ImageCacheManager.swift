//
//  ImageCacheManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import SwiftUI

final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let memoryCache = NSCache<NSString, CacheImage>()
    private let diskStorage = ImageCacheStorage()

    private init() {
        setupMemoryCache()
    }

    private func setupMemoryCache() {
        memoryCache.countLimit = 0  // (0 = 무제한 -> 메모리 크기만으로 관리)
        memoryCache.totalCostLimit = calculateOptimalMemorySize()
    }

    // 전체 메모리의 25% 설정 (Kingfisher)
    private func calculateOptimalMemorySize() -> Int {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4

        return (costLimit > Int.max) ? Int.max : Int(costLimit)
    }

    // MARK: - Public Methods

    /// 이미지 로드 (캐시 우선, 없으면 다운로드)
    func loadImage(
        from path: String,
        targetSize: CGSize = CGSize(width: 160, height: 120),
        accessTokenKey: String = KeychainType.accessToken.rawValue
    ) async -> UIImage? {
        let cacheKey = generateCacheKey(from: path)

        // 1. 메모리 캐시 확인
        if let cachedImage = getFromMemoryCache(key: cacheKey) {
            print("🎯 메모리 캐시 히트: \(path)")
            return cachedImage.image
        }

        // 2. 디스크 캐시 확인
        if let cachedImage = await diskStorage.loadImage(for: cacheKey) {
            print("💾 디스크 캐시 히트: \(path)")
            // 메모리 캐시에도 저장
            setToMemoryCache(key: cacheKey, image: cachedImage)
            return cachedImage.image
        }

        // 3. 서버에서 ETag 확인
        let currentETag = await getETagFromServer(path: path, accessTokenKey: accessTokenKey)

        // 4. 캐시에 있는 ETag와 비교
        if let diskMetadata = await diskStorage.getMetadata(for: cacheKey),
           diskMetadata.etag == currentETag {
            print("🏷️ ETag 일치, 캐시 재사용: \(path)")
            // 이미지 파일 로드해서 메모리에 올리기
            if let cachedImage = await diskStorage.loadImage(for: cacheKey) {
                setToMemoryCache(key: cacheKey, image: cachedImage)
                return cachedImage.image
            }
        }

        // 5. 새로운 이미지 다운로드
        print("🌐 새 이미지 다운로드: \(path)")
        if let downloadedImage = await downloadImage(from: path, targetSize: targetSize, etag: currentETag, accessTokenKey: accessTokenKey) {
            // 메모리와 디스크에 저장
            await saveToCache(key: cacheKey, image: downloadedImage)
            return downloadedImage.image
        }

        return nil
    }

    /// 캐시 클리어
    func clearCache() {
        memoryCache.removeAllObjects()
        diskStorage.clearCache()
        print("🗑️ 캐시 전체 삭제 완료")
    }
}

// MARK: - Private Methods - 메모리 캐시
private extension ImageCacheManager {
    func getFromMemoryCache(key: String) -> CacheImage? {
        return memoryCache.object(forKey: NSString(string: key))
    }

    func setToMemoryCache(key: String, image: CacheImage) {
        let cost = image.fileSize
        memoryCache.setObject(image, forKey: NSString(string: key), cost: cost)
    }

    func saveToCache(key: String, image: CacheImage) async {
        // 메모리 캐시에 저장
        setToMemoryCache(key: key, image: image)

        // 디스크 캐시에 저장
        await diskStorage.saveImage(key: key, image: image)
    }
}

// MARK: - Private Methods - 네트워크
private extension ImageCacheManager {
    func getETagFromServer(path: String, accessTokenKey: String = KeychainType.accessToken.rawValue) async -> String? {
        guard let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(path)"),
              let accessToken = KeychainManager.shared.load(key: accessTokenKey) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.value(forHTTPHeaderField: "ETag")
            }
        } catch {
            print("❌ HEAD 요청 실패: \(error.localizedDescription)")
        }

        return nil
    }

    func downloadImage(from path: String, targetSize: CGSize, etag: String?, accessTokenKey: String = KeychainType.accessToken.rawValue) async -> CacheImage? {
        guard let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(path)"),
              let accessToken = KeychainManager.shared.load(key: accessTokenKey) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }

            // 이미지 다운샘플링
            if let downsampledImage = await ImageDownSampler.downsampleImage(from: data, to: targetSize, scale: UIScreen.main.scale) {
                let responseETag = httpResponse.value(forHTTPHeaderField: "ETag") ?? etag ?? ""

                return CacheImage(
                    image: downsampledImage,
                    etag: responseETag,
                    lastModified: Date(),
                    fileSize: data.count
                )
            }
        } catch {
            print("❌ 이미지 다운로드 실패: \(error.localizedDescription)")
        }

        return nil
    }
}

// MARK: - Private Methods - 유틸리티
private extension ImageCacheManager {
    func generateCacheKey(from path: String) -> String {
        return path.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}
