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

    func send(_ intent: ProfileEditIntent) {
        switch intent {
        case .saveTapped:
            reducer.reduce(state: &state, intent: .saveTapped)

            Task {
                if let image = state.selectedImage {
                    let uploadResult = await effect.uploadImage(image)

                    switch uploadResult {
                    case .success(let urlPath):
                        await MainActor.run {
                            reducer.reduce(state: &state, intent: .uploadImageSuccess(urlPath))
                            var updated = state.profile
                            updated.profileImageURL = urlPath
                            reducer.reduce(state: &state, intent: .updateProfile(updated))
                        }
                    case .failure(let error):
                        await MainActor.run {
                            reducer.reduce(state: &state, intent: .uploadImageFailure(error.message))
                            reducer.reduce(state: &state, intent: .saveFailure(error))
                        }
                        return
                    }
                }

                let result = await effect.saveProfile(profile: state.profile)
                await MainActor.run {
                    switch result {
                    case .success:
                        reducer.reduce(state: &state, intent: .saveSuccess)
                        router.pop()
                    case .failure(let error):
                        reducer.reduce(state: &state, intent: .saveFailure(error))
                    }
                }
            }

        case .uploadImage:
            guard let uiImage = state.selectedImage else { return }

            Task {
                let result = await effect.uploadImage(uiImage)
                await MainActor.run {
                    switch result {
                    case .success(let urlPath):
                        reducer.reduce(state: &state, intent: .uploadImageSuccess(urlPath))
                    case .failure(let error):
                        reducer.reduce(state: &state, intent: .uploadImageFailure(error.message))
                    }
                }
            }

        case .updateProfile,
             .toggleImagePicker,
             .updateSelectedImage,
             .uploadImageSuccess,
             .uploadImageFailure,
             .saveSuccess,
             .saveFailure:
            reducer.reduce(state: &state, intent: intent)

        case .loadRemoteImage(let image):
            reducer.reduce(state: &state, intent: .loadRemoteImage(image))

        case .loadRemoteImageFailed(let errorMessage):
            reducer.reduce(state: &state, intent: .loadRemoteImageFailed(errorMessage))
        }
    }

    func loadInitialImageIfNeeded() {
        effect.loadRemoteImage(for: state.profile.profileImageURL, store: self)
    }
}

extension ProfileEditStore {
    func onImageLoaded(_ image: UIImage) {
        send(.loadRemoteImage(image))
    }

    func onImageLoadFailed(_ errorMessage: String) {
        send(.loadRemoteImageFailed(errorMessage))
    }
}
