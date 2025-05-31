//
//  ProfileEditEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileEditEffect {
    func saveProfile(profile: ProfileEntity) async -> Result<MeProfileResponse, APIError> {
        do {
            let request = profile.toRequest()
            let result = try await NetworkManager.shared.fetch(
                UserRouter.putProfile(request: request),
                successType: MeProfileResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                return .success(success)
            } else if let failure = result.failure {
                return .failure(.message(failure.message))
            } else {
                return .failure(.unknown)
            }
        } catch {
            return .failure(.message(error.localizedDescription))
        }
    }
}
