//
//  ProfileView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var store: ProfileStore

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
            store.send(.onAppear)
        }
    }

    private var profileCard: some View {
        let user = store.state.user
        return VStack(spacing: 16) {
            Group {
                if let imagePath = user.profileImage,
                   !imagePath.isEmpty,
                   let url = URL(string: "\(APIEnvironment.production.baseURL)/\(imagePath)") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .padding(20)
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
}

//#Preview {
//    let dummyRouter = AppRouter()
//    let mockUser = MeProfileResponse.mock
//    let mockViewModel = ProfileViewModel(router: dummyRouter, user: mockUser)
//    ProfileView(viewModel: mockViewModel)
//}
