//
//  ProfileEditStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import UIKit

final class ProfileEditStore: ObservableObject, ImageLoadRespondable {
    @Published private(set) var state: ProfileEditState
    private let reducer: ProfileEditReducer
    private let effect: ProfileEditEffect
    private let router: AppRouter

    init(
        state: ProfileEditState,
        reducer: ProfileEditReducer,
        effect: ProfileEditEffect,
        router: AppRouter
    ) {
        self.state = state
        self.reducer = reducer
        self.effect = effect
        self.router = router
    }

    func send(_ intent: ProfileEditAction.Intent) {
        reducer.reduce(state: &state, intent: intent)
        effect.handle(intent, store: self)
    }

    func send(_ result: ProfileEditAction.Result) {
        reducer.reduce(state: &state, result: result)
    }

    func handleSaveTapped() {
        Task {
            if let image = state.selectedImage {
                let uploadResult = await effect.uploadImage(image)
                await MainActor.run {
                    switch uploadResult {
                    case .success(let urlPath):
                        send(.uploadImageSuccess(urlPath))
                        var updated = state.profile
                        updated.profileImageURL = urlPath
                        send(.updateProfile(updated))
                    case .failure(let error):
                        send(.uploadImageFailure(error.message))
                        send(.saveFailure(error))
                        return
                    }
                }
            }

            let result = await effect.saveProfile(profile: state.profile)
            await MainActor.run {
                switch result {
                case .success:
                    send(.saveSuccess)
                    router.pop()
                case .failure(let error):
                    send(.saveFailure(error))
                }
            }
        }
    }

    func handleUploadImage() {
        guard let uiImage = state.selectedImage else { return }

        Task {
            let result = await effect.uploadImage(uiImage)
            await MainActor.run {
                switch result {
                case .success(let urlPath):
                    send(.uploadImageSuccess(urlPath))
                case .failure(let error):
                    send(.uploadImageFailure(error.message))
                }
            }
        }
    }

    func loadInitialImageIfNeeded() {
        effect.loadRemoteImage(for: state.profile.profileImageURL, store: self)
    }

    func onImageLoaded(_ image: UIImage) {
        send(.loadRemoteImage(image))
    }

    func onImageLoadFailed(_ errorMessage: String) {
        send(.loadRemoteImageFailed(errorMessage))
    }
}
