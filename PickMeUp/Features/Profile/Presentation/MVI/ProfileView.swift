//
//  ProfileView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct ProfileView: View {
    let store: ProfileStore

    var body: some View {
        VStack(spacing: 32) {
            if store.state.isLoading {
                ProgressView("프로필을 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.state.hasError {
                ProfileErrorView(
                    message: store.state.errorMessage ?? "알 수 없는 오류",
                    onRetry: { store.send(.onAppear) }
                )
            } else {
                profileCard
                Spacer()
            }
        }
        .padding(.top, 20)
        .background(Color.brightSprout.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            store.send(.onAppear)
        }
    }

    private var profileCard: some View {
        let user = store.state.user

        return VStack(spacing: 16) {
            // 프로필 이미지
            ProfileImageView(
                image: store.state.profileImage,
                hasImage: store.state.hasProfileImage
            )

            // 사용자 정보
            ProfileInfoView(
                displayName: store.state.displayName,
                email: user.email,
                phoneNumber: user.phoneNum
            )

            // 편집 버튼
            ProfileEditButton {
                store.send(.editProfileTapped)
            }
        }
        .padding()
        .background(Color.gray0)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
