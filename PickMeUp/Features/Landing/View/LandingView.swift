//
//  LandingView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel: LandingViewModel

    init(viewModel: LandingViewModel = LandingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Pick Me Up")
                .font(.title)
            Spacer()
            loginRegisterButtons()
            Spacer()
        }
        .background(Color(white: 0.95).ignoresSafeArea())
        .sheet(isPresented: Binding(
            get: { viewModel.state.isShowingRegister },
            set: { _ in } // ViewModel에서만 상태를 바꾸므로 Set은 비워둠
        )) {
            RegisterView()
        }
    }

    @ViewBuilder
    private func loginRegisterButtons() -> some View {
        VStack(spacing: 12) {
            PrimaryButton(action: { viewModel.handleIntent(.registerTapped) }) {
                Text("로그인")
            }
            PrimaryButton(action: { viewModel.handleIntent(.appleLoginTapped) }) {
                HStack {
                    Image("apple")
                    Text("Sign in with Apple")
                }
            }
            PrimaryButton(action: { viewModel.handleIntent(.kakaoLoginTapped) }) {
                Image("kakao_login_button")
                    .resizable()
            }
            PrimaryButton(action: { viewModel.handleIntent(.registerTapped) }) {
                Text("회원가입")
            }
        }
    }
}

#Preview {
    let viewModel = LandingViewModel(initialState: LandingState(isShowingRegister: true))
    return LandingView(viewModel: viewModel)
}
