//
//  ProfileEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileEffect {
    func handleOnAppear(store: ProfileStore) {
        Task {
            do {
                let result = try await NetworkManager.shared.fetch(
                    UserRouter.getProfile,
                    successType: MeProfileResponse.self,
                    failureType: CommonMessageResponse.self
                )
                if let user = result.success {
                    await MainActor.run {
                        store.send(.fetchProfile(user))
                    }
                } else if let failure = result.failure {
                    await MainActor.run {
                        store.send(.fetchFailed(failure.message))
                    }
                } else {
                    await MainActor.run {
                        store.send(.fetchFailed("알 수 없는 오류 발생"))
                    }
                }
            } catch {
                await MainActor.run {
                    store.send(.fetchFailed(error.localizedDescription))
                }
            }
        }
    }
}
