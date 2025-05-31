//
//  ProfileEditView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

struct ProfileEditView: View {
    @StateObject private var viewModel: ProfileEditViewModel

    init(viewModel: ProfileEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            profileEditCard
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileEditView {
    var profileEditCard: some View {
        VStack(spacing: 16) {
            // ✅ 이미지 표시 로직
            if let imagePath = viewModel.state.profile.profileImageURL,
               !imagePath.isEmpty,
               let url = URL(string: "https://yourdomain.com\(imagePath)") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 4)
            }

            VStack(spacing: 8) {
                TextField("닉네임", text: Binding(
                    get: { viewModel.state.profile.nick },
                    set: { viewModel.handleIntent(.updateNick($0)) }
                ))
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

                TextField("전화번호", text: Binding(
                    get: { viewModel.state.profile.phone },
                    set: { viewModel.handleIntent(.updatePhoneNum($0)) }
                ))
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
            }

            if let error = viewModel.state.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                viewModel.handleIntent(.saveTapped)
            }) {
                if viewModel.state.isSaving {
                    ProgressView()
                } else {
                    Text("저장하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.state.isSaveButtonEnabled ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(!viewModel.state.isSaveButtonEnabled || viewModel.state.isSaving)
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
//#Preview {
//    ProfileEditView(viewModel: <#ProfileEditViewModel#>)
//}
