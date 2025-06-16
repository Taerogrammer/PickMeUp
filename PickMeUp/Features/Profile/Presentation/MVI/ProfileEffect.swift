//
//  ProfileEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ProfileEffect {
    func handle(_ action: ProfileAction.Intent, store: ProfileStore) {
        switch action {
        case .onAppear:
            Task {
                await loadProfile(store: store)
            }

        case .loadProfileImage(let imagePath):
            Task {
                await loadProfileImage(store: store, imagePath: imagePath)
            }

        case .editProfileTapped:
            if let profile = store.state.profile {
                Task { @MainActor in
                    store.router.navigate(to: .editProfile(user: profile))
                }
            }
        }
    }

    @MainActor
    private func loadProfile(store: ProfileStore) async {
        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.getProfile,
                successType: MeProfileResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let user = result.success {
                store.send(.profileLoaded(user))

                if let path = user.profileImage, !path.isEmpty {
                    store.send(.loadProfileImage(path))
                } else {
                    store.send(.profileImageLoadFailed("기본 이미지 사용"))
                }
            } else if let failure = result.failure {
                store.send(.profileLoadFailed(failure.message))
            } else {
                store.send(.profileLoadFailed("알 수 없는 오류 발생"))
            }
        } catch {
            store.send(.profileLoadFailed(error.localizedDescription))
        }
    }

    @MainActor
    private func loadProfileImage(store: ProfileStore, imagePath: String) async {
        guard
            !imagePath.isEmpty,
            let url = URL(string: "\(APIEnvironment.production.baseURL)/v1\(imagePath)"),
            let accessToken = KeychainManager.shared.load(key: "accessToken")
        else {
            store.send(.profileImageLoadFailed("잘못된 이미지 경로 또는 토큰 없음"))
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
                store.send(.profileImageLoaded(image))
            } else {
                store.send(.profileImageLoadFailed("이미지 디코딩 실패"))
            }
        } catch {
            store.send(.profileImageLoadFailed(error.localizedDescription))
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
