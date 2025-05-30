//
//  ProfileViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Combine
import Foundation

final class ProfileViewModel: NSObject, ObservableObject {
    @Published var state: ProfileState
    let router: AppRouter

    @Published var user: MeProfileResponse
    @Published var profile: ProfileEntity?

    init(state: ProfileState = ProfileState(), router: AppRouter, user: MeProfileResponse) {
        self.state = state
        self.router = router
        self.user = user
        self.profile = user.toEntity()
    }

    func handleIntent(_ intent: ProfileIntent) {
        switch intent {
        case .editProfileTapped:
            navigateToEditProfile()
        }
    }

    func navigateToEditProfile() {
        guard let profile else { return }
        router.navigate(to: .editProfile(user: profile))
    }
}

extension ProfileViewModel {
    func fetchProfile() async {
        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.getProfile,
                successType: MeProfileResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                if let success = result.success {
                    self.user = success
                    self.profile = success.toEntity()
                } else if let failure = result.failure {
                    print("❌ [프로필 조회 실패]: \(failure.message)")
                } else {
                    print("❌ [프로필 조회 실패]: 알 수 없는 오류 발생")
                }
            }

        } catch {
            await MainActor.run {
                print("❌ [네트워크 오류]: \(error.localizedDescription)")
            }
        }
    }
}
