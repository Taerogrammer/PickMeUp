//
//  ProfileEditViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

final class ProfileEditViewModel: ObservableObject {
    @Published var state: ProfileEditState
    private let router: AppRouter

    init(initialState: ProfileEditState = ProfileEditState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func handleIntent(_ intent: ProfileEditIntent) {
        switch intent {
        case .updateNick(let nick):
            var updated = state.profile
            updated = ProfileEntity(
                nick: nick,
                email: updated.email,
                phone: updated.phone,
                profileImageURL: updated.profileImageURL
            )
            state.profile = updated

        case .updatePhoneNum(let phone):
            var updated = state.profile
            updated = ProfileEntity(
                nick: updated.nick,
                email: updated.email,
                phone: phone,
                profileImageURL: updated.profileImageURL
            )
            state.profile = updated

        case .updateProfileImage(let url):
            var updated = state.profile
            updated = ProfileEntity(
                nick: updated.nick,
                email: updated.email,
                phone: updated.phone,
                profileImageURL: url
            )
            state.profile = updated

        case .saveTapped:
            saveProfile()
        }
    }

    private func saveProfile() {
        state.isSaving = true
        state.errorMessage = nil

        let request = state.profile.toRequest()

        Task {
            do {
                let result = try await NetworkManager.shared.fetch(
                    UserRouter.putProfile(request: request),
                    successType: MeProfileResponse.self,
                    failureType: CommonMessageResponse.self
                )

                await MainActor.run {
                    if let success = result.success {
                        print("✅ 수정 성공: \(success)")
                        router.pop()
                    } else if let failure = result.failure {
                        state.errorMessage = failure.message
                    } else {
                        state.errorMessage = "알 수 없는 오류가 발생했습니다"
                    }
                    state.isSaving = false
                }
            } catch {
                await MainActor.run {
                    state.errorMessage = "요청 실패: \(error.localizedDescription)"
                    state.isSaving = false
                }
            }
        }
    }

    
}
