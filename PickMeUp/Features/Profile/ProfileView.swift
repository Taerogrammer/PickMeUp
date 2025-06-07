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
        .background(Color.brightSprout.ignoresSafeArea()) // ✅ 밝은 배경 적용
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
                if let image = store.state.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray45)
                        .padding(20)
                }
            }
            .frame(width: 100, height: 100)
            .background(Color.gray0)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray30, lineWidth: 2))
            .shadow(radius: 4)

            VStack(spacing: 4) {
                Text(user.nick)
                    .font(.pretendardTitle1)
                    .foregroundColor(.gray90)

                Text(user.email)
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)

                Text(user.phoneNum)
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)
            }

            Button {
                store.send(.editProfileTapped)
            } label: {
                HStack {
                    Text("프로필 수정")
                        .foregroundColor(.gray90)
                        .font(.pretendardBody2)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray60)
                }
                .padding()
                .background(Color.gray15)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray0)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    let dummyRouter = AppRouter()
    let dummyUser = MeProfileResponse.mock
    let dummyState = ProfileState(user: dummyUser)
    let store = ProfileStore(
        state: dummyState,
        effect: ProfileEffect(),
        reducer: ProfileReducer(),
        router: dummyRouter
    )
    return ProfileView(store: store)
}
