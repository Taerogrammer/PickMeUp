//
//  ImageLoader.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

enum ImageLoader {
    /// 캐시 시스템을 사용한 이미지 로딩
    static func load(
        from path: String,
        targetSize: CGSize = CGSize(width: 160, height: 120),
        scale: CGFloat = UIScreen.main.scale,
        accessTokenKey: String = TokenType.accessToken.rawValue,
        responder: ImageLoadRespondable
    ) {
        Task {
            if let image = await ImageCacheManager.shared.loadImage(from: path, targetSize: targetSize) {
                await MainActor.run {
                    responder.onImageLoaded(image)
                }
            } else {
                await MainActor.run {
                    responder.onImageLoadFailed("이미지 로드 실패")
                }
            }
        }
    }

    /// 직접 async/await 방식으로 이미지 로딩
    static func loadAsync(
        from path: String,
        targetSize: CGSize = CGSize(width: 160, height: 120),
        scale: CGFloat = 3.0,   // 대부분의 현대 기기 3x 스케일 사용
        accessTokenKey: String = TokenType.accessToken.rawValue
    ) async -> UIImage? {
        return await ImageCacheManager.shared.loadImage(from: path, targetSize: targetSize)
    }

    /// 여러 이미지 병렬 로딩
    static func loadMultiple(
        paths: [String],
        targetSizes: [CGSize]
    ) async -> [UIImage?] {
        let maxImages = min(paths.count, targetSizes.count)

        return await withTaskGroup(of: (Int, UIImage?).self, returning: [UIImage?].self) { group in
            var results: [UIImage?] = Array(repeating: nil, count: maxImages)

            for (index, path) in paths.prefix(maxImages).enumerated() {
                group.addTask {
                    let targetSize = index < targetSizes.count ? targetSizes[index] : CGSize(width: 92, height: 62)
                    let image = await ImageCacheManager.shared.loadImage(from: path, targetSize: targetSize)
                    return (index, image)
                }
            }

            for await (index, image) in group {
                if index < results.count {
                    results[index] = image
                }
            }

            return results
        }
    }

    /// 캐시 정리
    static func clearCache() {
        ImageCacheManager.shared.clearCache()
    }
}

//enum HeadRequestTester {
//
//    static func testHeadRequest() {
//        Task {
//            print("🧪 [HEAD 요청 테스트] 시작")
//
//            let imagePath = "/data/stores/chad-montano-MqT0asuoIcU-unsplash_1747128644346.jpg"
//
//            await performHeadRequest(imagePath: imagePath)
//        }
//    }
//
//    private static func performHeadRequest(imagePath: String) async {
//        guard let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(imagePath)"),
//              let accessToken = KeychainManager.shared.load(key: TokenType.accessToken.rawValue) else {
//            print("❌ URL 생성 실패")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "HEAD"  // 🎯 HEAD 요청
//        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
//        request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)
//
//        do {
//            print("📡 HEAD 요청 전송 중...")
//            print("   URL: \(url.absoluteString)")
//            print("   Method: HEAD")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ 응답 타입 오류")
//                return
//            }
//
//            print("\n✅ HEAD 요청 응답 받음")
//            print("   상태 코드: \(httpResponse.statusCode)")
//            print("   데이터 크기: \(data.count) bytes")
//
//            if let etag = httpResponse.value(forHTTPHeaderField: "ETag") {
//                print("   🏷️ ETag: \(etag)")
//            } else {
//                print("   ⚠️ ETag 헤더 없음")
//            }
//
//            if let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") {
//                print("   📏 Content-Length: \(contentLength)")
//            }
//
//            // 🎯 결과 분석
//            analyzeHeadRequestResult(statusCode: httpResponse.statusCode, dataSize: data.count)
//
//        } catch {
//            print("❌ HEAD 요청 실패: \(error.localizedDescription)")
//        }
//    }
//
//    private static func analyzeHeadRequestResult(statusCode: Int, dataSize: Int) {
//        print("\n🎯 [HEAD 요청 분석]")
//
//        switch statusCode {
//        case 200:
//            if dataSize == 0 {
//                print("✅ HEAD 요청 성공!")
//                print("   → 헤더만 받음, 데이터 0 bytes")
//                print("   → ETag 확인 용도로 사용 가능 🚀")
//            } else {
//                print("⚠️ HEAD 요청 성공하지만 데이터도 받음")
//                print("   → 데이터 크기: \(dataSize) bytes")
//                print("   → 서버가 HEAD를 GET처럼 처리함")
//            }
//
//        case 405:
//            print("❌ HEAD 메서드 지원 안 함 (405 Method Not Allowed)")
//            print("   → HEAD 요청 불가능")
//            print("   → 다른 방법 찾아야 함")
//
//        default:
//            print("❌ 예상치 못한 응답: \(statusCode)")
//        }
//    }
//}
//
//// MARK: - 대안 방법들
//
//enum AlternativeCachingStrategies {
//
//    /// 대안 1: Range 요청 (첫 1KB만)
//    static func testRangeRequest() {
//        Task {
//            print("🧪 [Range 요청 테스트] 시작")
//
//            let imagePath = "/data/stores/chad-montano-MqT0asuoIcU-unsplash_1747128644346.jpg"
//
//            await performRangeRequest(imagePath: imagePath)
//        }
//    }
//
//    private static func performRangeRequest(imagePath: String) async {
//        guard let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(imagePath)"),
//              let accessToken = KeychainManager.shared.load(key: TokenType.accessToken.rawValue) else {
//            print("❌ URL 생성 실패")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
//        request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)
//        request.setValue("bytes=0-1023", forHTTPHeaderField: "Range")  // 🎯 첫 1KB만
//
//        do {
//            print("📡 Range 요청 전송 중 (첫 1KB만)...")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ 응답 타입 오류")
//                return
//            }
//
//            print("✅ Range 요청 응답")
//            print("   상태 코드: \(httpResponse.statusCode)")
//            print("   데이터 크기: \(data.count) bytes")
//
//            if let etag = httpResponse.value(forHTTPHeaderField: "ETag") {
//                print("   🏷️ ETag: \(etag)")
//            }
//
//            if httpResponse.statusCode == 206 {
//                print("✅ Partial Content 지원!")
//                print("   → Range 요청으로 ETag 확인 가능")
//            } else if httpResponse.statusCode == 200 {
//                print("⚠️ Range 무시, 전체 데이터 응답")
//            }
//
//        } catch {
//            print("❌ Range 요청 실패: \(error.localizedDescription)")
//        }
//    }
//
//    /// 대안 2: 파일명 기반 캐싱
//    static func fileNameBasedCaching() {
//        print("🧪 [파일명 기반 캐싱] 전략")
//        print("   → URL에 타임스탬프 포함: image_1747128644346.jpg")
//        print("   → 파일명이 같으면 같은 이미지로 가정")
//        print("   → 네트워크 요청 완전 생략 가능")
//        print("   → 단점: 이미지 변경 감지 못함")
//    }
//
//    /// 대안 3: 조건부 GET + 타임아웃
//    static func conditionalGetWithTimeout() {
//        print("🧪 [조건부 GET + 타임아웃] 전략")
//        print("   → 30분 이내: 네트워크 요청 생략")
//        print("   → 30분 후: ETag 포함 GET 요청")
//        print("   → 서버가 200 응답해도 ETag 비교 후 캐시 사용")
//        print("   → 현실적인 절충안")
//    }
//}
//
//// MARK: - 통합 테스트
//
//enum CachingStrategyTest {
//
//    static func testAllStrategies() {
//        print("🎯 [캐싱 전략 종합 테스트]")
//
//        // 1. HEAD 요청 테스트
//        HeadRequestTester.testHeadRequest()
//
//        // 3초 후 Range 요청 테스트
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            AlternativeCachingStrategies.testRangeRequest()
//        }
//
//        // 6초 후 대안 전략 출력
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            AlternativeCachingStrategies.fileNameBasedCaching()
//            AlternativeCachingStrategies.conditionalGetWithTimeout()
//        }
//    }
//}
