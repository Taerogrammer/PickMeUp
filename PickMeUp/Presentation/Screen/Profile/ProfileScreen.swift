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
        VStack(spacing: 32) {
            ProfileView(store: store)
            profileMenuList
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }

    private var profileMenuList: some View {
        VStack(spacing: 0) {
            profileMenuItem(title: "자주 묻는 질문")
            Divider().background(Color.gray)
            profileMenuItem(title: "1:1 문의")
            Divider().background(Color.gray)
            profileMenuItem(title: "알림 설정")
            Divider().background(Color.gray)
            profileMenuItem(title: "탈퇴하기", textColor: .red)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func profileMenuItem(title: String, textColor: Color = .white) -> some View {
        HStack {
            Text(title)
                .foregroundColor(textColor)
                .font(.body)
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
