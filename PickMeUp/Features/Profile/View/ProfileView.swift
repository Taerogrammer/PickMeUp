//
//  ProfileView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            profileCard
            profileMenuList
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchProfile() }
    }
}

private extension ProfileView {
    var profileCard: some View {
        VStack(spacing: 16) {
            // ✅ profileImage가 있을 경우 → AsyncImage, 없을 경우 → 기본 person 아이콘
            Group {
                if let imagePath = viewModel.user.profileImage,
                   let url = URL(string: "https://yourdomain.com\(imagePath)") {
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
                        .padding(20) // 아이콘이 너무 작지 않도록 패딩
                }
            }
            .frame(width: 100, height: 100)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 4)

            VStack(spacing: 8) {
                Text(viewModel.user.nick)
                    .font(.title2).bold().foregroundColor(.white)

                Text(viewModel.user.email)
                    .font(.subheadline).foregroundColor(.gray)

                Text(viewModel.user.phoneNum)
                    .font(.subheadline).foregroundColor(.gray)

                Text("가입일: 25.01.23")
                    .font(.footnote).foregroundColor(.gray)
            }

            editProfileButton
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}



private extension ProfileView {
    var editProfileButton: some View {
        Button {
            viewModel.handleIntent(.editProfileTapped)
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
}

private extension ProfileView {
    var profileMenuList: some View {
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
    func profileMenuItem(title: String, textColor: Color = .white) -> some View {
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
    let dummyRouter = AppRouter()
    let mockUser = MeProfileResponse.mock
    let mockViewModel = ProfileViewModel(router: dummyRouter, user: mockUser)
    ProfileView(viewModel: mockViewModel)
}
