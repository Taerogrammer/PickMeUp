//
//  ProfileView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var store: ProfileStore
    @State private var profileImage: UIImage?

    init(store: ProfileStore) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        VStack(spacing: 32) {
            profileCard
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            print("🟡 Task started")
            store.send(.onAppear)
        }
        .onChange(of: store.state.user.profileImage) { newPath in
            print("🔁 imagePath changed:", newPath)
            Task {
                await loadProfileImage(for: newPath)
            }
        }
    }

    private var profileCard: some View {
        let user = store.state.user

        return VStack(spacing: 16) {
            Group {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }
            }
            .frame(width: 100, height: 100)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 4)

            VStack(spacing: 8) {
                Text(user.nick)
                    .font(.title2).bold().foregroundColor(.white)

                Text(user.email)
                    .font(.subheadline).foregroundColor(.gray)

                Text(user.phoneNum)
                    .font(.subheadline).foregroundColor(.gray)

                Text("가입일: 25.01.23")
                    .font(.footnote).foregroundColor(.gray)
            }

            Button {
                store.send(.editProfileTapped)
            } label: {
                HStack {
                    Text("프로필 수정")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray5).opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private func loadProfileImage(for imagePath: String?) async {
        print(#function)

        print("🟡 imagePath:", imagePath ?? "nil")
        let accessToken = KeychainManager.shared.load(key: "accessToken")
        print("🟡 accessToken:", accessToken ?? "nil")

        guard
            let imagePath = imagePath,
            !imagePath.isEmpty,
            let url = URL(string: "\(APIEnvironment.production.baseURL)/v1/\(imagePath)"),
            let accessToken = accessToken
        else {
            print("❌ 이미지 요청을 위한 정보 부족")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(APIConstants.Headers.Values.sesacKeyValue(), forHTTPHeaderField: APIConstants.Headers.sesacKey)

        printCurlCommand(for: request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Status:", httpResponse.statusCode)
            }

            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.profileImage = image
                }
                print("✅ Profile Image Loaded: \(url.absoluteString)")
            } else {
                print("❌ 이미지 데이터 디코딩 실패")
            }
        } catch {
            print("❌ Failed to load profile image: \(error.localizedDescription)")
        }
    }


    private func printCurlCommand(for request: URLRequest) {
        guard let url = request.url else { return }

        var components: [String] = ["curl"]

        // HTTP Method
        let method = request.httpMethod ?? "GET"
        if method != "GET" {
            components.append("-X \(method)")
        }

        // Headers
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                components.append("-H \"\(key): \(value)\"")
            }
        }

        // Body
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }

        // URL
        components.append("\"\(url.absoluteString)\"")

        let curlCommand = components.joined(separator: " \\\n  ")
        print("📡 cURL Request:\n\(curlCommand)")
    }
}

//#Preview {
//    let dummyRouter = AppRouter()
//    let mockUser = MeProfileResponse.mock
//    let mockViewModel = ProfileViewModel(router: dummyRouter, user: mockUser)
//    ProfileView(viewModel: mockViewModel)
//}
