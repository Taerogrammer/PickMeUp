//
//  ImageCacheStorage.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import SwiftUI

// MARK: - 디스크 캐시 스토리지
final class ImageCacheStorage {
    private let diskCacheURL: URL
    private let metadataURL: URL
    private let fileManager = FileManager.default
    private let cacheQueue = DispatchQueue(label: "ImageCacheStorageQueue", qos: .utility)

    // 캐시 설정
    private let maxDiskCacheSize: Int64 = 1024 * 1024 * 1024 // 1GB
    private let cacheExpireTime: TimeInterval = 30 * 24 * 60 * 60    // 30일 (마지막 접근 기준)

    init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDir.appendingPathComponent("ImageCache")
        metadataURL = diskCacheURL.appendingPathComponent("metadata.json")

        setupDiskCache()
    }

    private func setupDiskCache() {
        // 디스크 캐시 디렉토리 생성
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)

        // 앱 시작시 30일간 접근되지 않은 캐시 정리
        cleanExpiredCache()
    }

    // MARK: - 디스크에서 이미지 로드
    func loadImage(for key: String) async -> CacheImage? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }

                let result = self.loadImageSync(key: key)

                // 이미지 로드 성공 시 접근 시간 갱신
                if result != nil { self.updateLastAccessDate(for: key) }

                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - 디스크에 이미지 저장
    func saveImage(key: String, image: CacheImage) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            cacheQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                self.saveImageSync(key: key, image: image)
                continuation.resume()
            }
        }
    }

    // MARK: - 메타 데이터만 로드
    func getMetadata(for key: String) async -> CacheMetaData? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async { [weak self] in
                let result = self?.getMetadataSync(key: key)
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - 캐시 정리
    func clearCache() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }

            try? self.fileManager.removeItem(at: self.diskCacheURL)
            try? self.fileManager.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
            print("🗑️ 디스크 캐시 전체 삭제 완료")
        }
    } 
}

// MARK: - Private Methods - 동기 처리
private extension ImageCacheStorage {

    func loadImageSync(key: String) -> CacheImage? {
        guard let metadata = getMetadataSync(key: key) else { return nil }

        let imageURL = diskCacheURL.appendingPathComponent("\(key).jpg")
        guard let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else { return nil }

        return CacheImage(
            image: image,
            etag: metadata.etag,
            lastModified: metadata.lastModified,
            fileSize: metadata.fileSize
        )
    }

    func saveImageSync(key: String, image: CacheImage) {
        // 이미지 파일 저장
        let imageURL = diskCacheURL.appendingPathComponent("\(key).jpg")
        if let imageData = image.image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: imageURL)
        }

        // 메타데이터 저장
        let metadata = CacheMetaData(
            etag: image.etag,
            lastModified: image.lastModified,
            fileSize: image.fileSize,
            imagePath: "\(key).jpg",
            lastAccessDate: Date()
        )

        saveMetadata(key: key, metadata: metadata)
    }

    func getMetadataSync(key: String) -> CacheMetaData? {
        guard let allMetadata = loadAllMetadata() else { return nil }
        return allMetadata[key]
    }

    func updateLastAccessDate(for key: String) {
        guard var allMetaData = loadAllMetadata(), var metaData = allMetaData[key] else { return }
        metaData.lastAccessDate = Date()
        allMetaData[key] = metaData

        if let data = try? JSONEncoder().encode(allMetaData) { try? data.write(to: metadataURL) }
    }

    func saveMetadata(key: String, metadata: CacheMetaData) {
        var allMetadata = loadAllMetadata() ?? [:]
        allMetadata[key] = metadata

        if let data = try? JSONEncoder().encode(allMetadata) { try? data.write(to: metadataURL) }
    }

    func loadAllMetadata() -> [String: CacheMetaData]? {
        guard let data = try? Data(contentsOf: metadataURL) else { return nil }
        return try? JSONDecoder().decode([String: CacheMetaData].self, from: data)
    }

    func cleanExpiredCache() {
        guard let allMetadata = loadAllMetadata() else { return }

        let now = Date()
        var updatedMetadata = allMetadata

        for (key, metadata) in allMetadata {
            if now.timeIntervalSince(metadata.lastAccessDate) > cacheExpireTime {
                // 만료된 파일 삭제
                let imageURL = diskCacheURL.appendingPathComponent("\(key).jpg")
                try? fileManager.removeItem(at: imageURL)
                updatedMetadata.removeValue(forKey: key)
                print("🗑️ 만료된 캐시 삭제: \(key)")
            }
        }

        // 업데이트된 메타데이터 저장
        if let data = try? JSONEncoder().encode(updatedMetadata) {
            try? data.write(to: metadataURL)
        }
    }
}
