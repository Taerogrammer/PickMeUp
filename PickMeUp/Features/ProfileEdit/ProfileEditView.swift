//
//  ProfileEditView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

struct ProfileEditView: View {
    @StateObject private var store: ProfileEditStore

    init(store: ProfileEditStore) {
        _store = StateObject(wrappedValue: store)
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
            if let imagePath = store.state.profile.profileImageURL,
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
                    get: { store.state.profile.nick },
                    set: {
                        var updated = store.state.profile
                        updated.nick = $0
                        store.send(.updateProfile(updated))
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

                TextField("전화번호", text: Binding(
                    get: { store.state.profile.phone },
                    set: {
                        var updated = store.state.profile
                        updated.phone = $0
                        store.send(.updateProfile(updated))
                    }
                ))
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
            }

            if let error = store.state.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                store.send(.saveTapped)
            }) {
                if store.state.isSaving {
                    ProgressView()
                } else {
                    Text("저장하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(store.state.isSaveButtonEnabled ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(!store.state.isSaveButtonEnabled || store.state.isSaving)
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
