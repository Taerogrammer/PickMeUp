//
//  ProfileEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ProfileEffect {
    func handleOnAppear(store: ProfileStore) {
        Task {
            do {
                let result = try await NetworkManager.shared.fetch(
                    UserRouter.getProfile,
                    successType: MeProfileResponse.self,
                    failureType: CommonMessageResponse.self
                )
                if let user = result.success {
                    await MainActor.run {
                        store.send(.fetchProfile(user))

                        if let path = user.profileImage, !path.isEmpty {
                            store.send(.loadProfileImage(path))
                        } else {
                            store.send(.profileImageLoadFailed("기본 이미지 사용"))
                        }
                    }
                } else if let failure = result.failure {
                    await MainActor.run {
                        store.send(.fetchFailed(failure.message))
                    }
                } else {
                    await MainActor.run {
                        store.send(.fetchFailed("알 수 없는 오류 발생"))
                    }
                }
            } catch {
                await MainActor.run {
                    store.send(.fetchFailed(error.localizedDescription))
                }
            }
        }
    }

    func handleLoadProfileImage(store: ProfileStore, imagePath: String) {
        Task {
            guard
                !imagePath.isEmpty,
                let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(imagePath)"),
                let accessToken = KeychainManager.shared.load(key: "accessToken")
            else {
                await MainActor.run {
                    store.send(.profileImageLoadFailed("잘못된 이미지 경로 또는 토큰 없음"))
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

                if let image = UIImage(data: data) {
                    await MainActor.run {
                        store.send(.profileImageLoaded(image))
                    }
                } else {
                    await MainActor.run {
                        store.send(.profileImageLoadFailed("이미지 디코딩 실패"))
                    }
                }
            } catch {
                await MainActor.run {
                    store.send(.profileImageLoadFailed(error.localizedDescription))
                }
            }
        }
    }

    private func printCurlCommand(for request: URLRequest) {
        guard let url = request.url else { return }

        var components: [String] = ["curl"]

        let method = request.httpMethod ?? "GET"
        if method != "GET" {
            components.append("-X \(method)")
        }

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                components.append("-H \"\(key): \(value)\"")
            }
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }

        components.append("\"\(url.absoluteString)\"")
        print("📡 cURL Request:\n" + components.joined(separator: " \\\n  "))
    }
}
