//
//  ProfileScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ProfileScreen: View {
    let store: ProfileStore

    init(store: ProfileStore) {
        self.store = store
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileView(store: store)
                profileMenuList
            }
        }
        .background(Color.brightSprout.ignoresSafeArea())
    }

    private var profileMenuList: some View {
        VStack(spacing: 0) {
            profileMenuItem(title: "자주 묻는 질문")
            Divider().background(Color.gray30)
            profileMenuItem(title: "1:1 문의")
            Divider().background(Color.gray30)
            profileMenuItem(title: "알림 설정")
            Divider().background(Color.gray30)
            profileMenuItem(title: "탈퇴하기", textColor: .brightForsythia)
        }
        .padding(.horizontal)
        .padding(.top, 8) // 약간의 여유 간격만 유지
    }

    @ViewBuilder
    private func profileMenuItem(title: String, textColor: Color = .gray90) -> some View {
        HStack {
            Text(title)
                .foregroundColor(textColor)
                .font(.pretendardBody2)
            Spacer()
        }
        .padding(.vertical, 16)
    }
}


#Preview {
    let state = ProfileState(
        user: MeProfileResponse(
            user_id: "1",
            email: "example@example.com",
            nick: "닉네임",
            profileImage: "",
            phoneNum: "010-1234-5678"
        )
    )
    let reducer = ProfileReducer()
    let effect = ProfileEffect()
    let store = ProfileStore(
        state: state,
        effect: effect,
        reducer: reducer,
        router: AppRouter()
    )
    ProfileScreen(store: store)
}
