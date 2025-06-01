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
        .sheet(isPresented: Binding(
            get: { store.state.showImagePicker },
            set: { store.send(.toggleImagePicker($0)) }
        )) {
            ImagePicker(image: Binding<UIImage?>(
                get: { store.state.selectedImage },
                set: {
                    if let image = $0 {
                        store.send(.updateSelectedImage(image))
                        store.send(.uploadImage)
                    }
                }
            ))
        }
        .task {
            store.loadInitialImageIfNeeded()
        }
    }

    private var profileEditCard: some View {
        VStack(spacing: 16) {
            profileImageView

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

    private var profileImageView: some View {
        Group {
            if let selected = store.state.selectedImage {
                Image(uiImage: selected)
                    .resizable()
            } else if let remote = store.state.remoteImage {
                Image(uiImage: remote)
                    .resizable()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .scaledToFit()
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(radius: 4)
        .onTapGesture {
            store.send(.toggleImagePicker(true))
        }
    }
}

#Preview("ProfileEditView") {
    let dummyRouter = AppRouter()
    let dummyProfile = ProfileEntity(
        nick: "PreviewUser",
        email: "preview@example.com",
        phone: "010-9999-8888",
        profileImageURL: nil
    )
    let dummyState = ProfileEditState(profile: dummyProfile)
    let store = ProfileEditStore(
        state: dummyState,
        reducer: ProfileEditReducer(),
        effect: ProfileEditEffect(),
        router: dummyRouter
    )
    return ProfileEditView(store: store)
}
