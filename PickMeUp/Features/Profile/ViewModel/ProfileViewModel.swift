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

    init(state: ProfileState = ProfileState(), router: AppRouter, user: MeProfileResponse) {
        self.state = state
        self.router = router
        self.user = user
    }

    func handleIntent(_ intent: ProfileIntent) {
        switch intent {
        case .editProfileTapped:
            navigateToEditProfile()
        }
    }

    func navigateToEditProfile() {
        router.navigate(to: .editProfile)
    }
}
