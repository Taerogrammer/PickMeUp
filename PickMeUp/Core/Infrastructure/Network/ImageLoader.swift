//
//  ImageLoader.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

enum ImageLoader {
    static func load(
        from path: String,
        targetSize: CGSize = CGSize(width: 160, height: 120),
        scale: CGFloat = UIScreen.main.scale,
        accessTokenKey: String = TokenType.accessToken.rawValue,
        responder: ImageLoadRespondable
    ) {
        Task {
            guard
                !path.isEmpty,
                let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(path)"),
                let accessToken = KeychainManager.shared.load(key: accessTokenKey)
            else {
                await MainActor.run {
                    responder.onImageLoadFailed("잘못된 이미지 경로 또는 토큰 없음")
                }
                return
            }

            var request = URLRequest(url: url)
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)

            printCurlCommand(for: request)

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    print("🌐 HTTP Status:", httpResponse.statusCode)
                }

                if let downsampledImage = ImageDownSampler.downsampleImage(from: data, to: targetSize, scale: scale) {
                    await MainActor.run {
                        responder.onImageLoaded(downsampledImage)
                    }
                } else {
                    await MainActor.run {
                        responder.onImageLoadFailed("이미지 디코딩 실패")
                    }
                }
            } catch {
                await MainActor.run {
                    responder.onImageLoadFailed(error.localizedDescription)
                }
            }
        }
    }

    private static func printCurlCommand(for request: URLRequest) {
        guard let url = request.url else { return }

        var components: [String] = ["curl"]
        if let method = request.httpMethod, method != "GET" {
            components.append("-X \(method)")
        }
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                components.append("-H \"\(key): \(value)\"")
            }
        }
        components.append("\"\(url.absoluteString)\"")
        print("📡 cURL Request:\n" + components.joined(separator: " \\\n  "))
    }
}
