//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
    @Published var state: LandingState
    @Published var resultMessage: String?

    private let router: AppRouter

    init(initialState: LandingState = LandingState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func onAppear() async {
        await validateEmail("sesac123214@gmail.com")
    }

    func handleIntent(_ intent: LandingIntent) {
        switch intent {
        case .registerTapped:
            router.navigate(to: .register)
        case .appleLoginTapped:
            print("애플 로그인 처리")
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        }
    }

    private func validateEmail(_ email: String) async {
        do {
            let response: CommonMessageResponse = try await NetworkManager.shared.request(
                PickupRouter.validateEmail(email: email),
                responseType: CommonMessageResponse.self
            )
            resultMessage = response.message
        } catch let error as APIError {
            switch error {
            case .serverMessage(let serverMessage):
                resultMessage = "서버 에러: \(serverMessage)"
            default:
                resultMessage = error.localizedDescription
            }
        } catch {
            resultMessage = "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}
