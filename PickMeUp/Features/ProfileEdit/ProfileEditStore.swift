//
//  ProfileEditStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Combine
import Foundation

final class ProfileEditStore: ObservableObject {
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
                // 1. 이미지 업로드가 필요하면 먼저 실행
                if let image = state.selectedImage {
                    let uploadResult = await effect.uploadImage(image, format: .jpeg)

                    switch uploadResult {
                    case .success(let urlPath):
                        await MainActor.run {
                            // 업로드 성공 처리
                            reducer.reduce(state: &state, intent: .uploadImageSuccess(urlPath))

                            // ✅ 업로드한 이미지 URL을 profile에 반영
                            var updated = state.profile
                            updated.profileImageURL = urlPath
                            reducer.reduce(state: &state, intent: .updateProfile(updated))
                        }

                    case .failure(let error):
                        await MainActor.run {
                            reducer.reduce(state: &state, intent: .uploadImageFailure(error.message))
                            reducer.reduce(state: &state, intent: .saveFailure(error)) // 저장도 중단
                        }
                        return // 이미지 업로드 실패 시 저장 중단
                    }
                }

                // 2. 프로필 저장
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
                let result = await effect.uploadImage(uiImage, format: .jpeg)
                await MainActor.run {
                    switch result {
                    case .success(let urlPath):
                        reducer.reduce(state: &state, intent: .uploadImageSuccess(urlPath))

                        // 이곳에서는 updateProfile 호출은 필요하지 않음
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
        }
    }
}
