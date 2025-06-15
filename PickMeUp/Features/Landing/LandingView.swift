//
//  LandingView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct LandingView: View {
    @StateObject private var store: LandingStore
    private let container: DIContainer

    init(store: LandingStore, container: DIContainer) {
        _store = StateObject(wrappedValue: store)
        self.container = container
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Pick Me Up")
                .font(.title)

            Spacer()
            VStack(spacing: 16) {
                TextField("Email", text: Binding(
                    get: { store.state.email },
                    set: { store.send(.updateEmail($0)) }  // Intent
                ))
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

                PasswordField(
                    title: "Password",
                    text: store.state.password,
                    isPasswordVisible: store.state.isPasswordVisible,
                    validationMessage: nil,
                    onChange: { store.send(.updatePassword($0)) },  // Intent
                    onToggleVisibility: { store.send(.togglePasswordVisibility) }  // Intent
                )

                if let error = store.state.loginErrorMessage {
                    Text(error).foregroundColor(.red).font(.footnote)
                }

                PrimaryButton(action: { store.send(.login) }) {
                    HStack {
                        if store.state.isLoginLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(store.state.isLoginLoading ? "로그인 중..." : "로그인")
                    }
                }
                .disabled(store.state.isLoading)
            }
            .padding(.horizontal, 20)

            Spacer()
            loginRegisterButtons()
            Spacer()
        }
        .background(Color(white: 0.95).ignoresSafeArea())
    }

    @ViewBuilder
    private func loginRegisterButtons() -> some View {
        VStack(spacing: 12) {
            PrimaryButton(action: { store.send(.registerTapped) }) {
                Text("회원가입")
            }

            PrimaryButton(action: { store.send(.appleLoginTapped) }) {
                HStack {
                    if store.state.isAppleLoginLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }
                    Image("apple")
                    Text(store.state.isAppleLoginLoading ? "Apple 로그인 중..." : "Sign in with Apple")
                }
            }
            .disabled(store.state.isLoading)

            PrimaryButton(action: { store.send(.kakaoLoginTapped) }) {
                if store.state.isKakaoLoginLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                        Text("카카오 로그인 중...")
                    }
                } else {
                    Image("kakao_login_button")
                        .resizable()
                }
            }
            .disabled(store.state.isLoading)
        }
    }
}


//#Preview {
//    let dummyRouter = AppRouter()
//    let viewModel = LandingViewModel(initialState: LandingState(isShowingRegister: false), router: dummyRouter, appLaunchState: <#AppLaunchState#>)
//    LandingView(viewModel: viewModel, container: DIContainer())
//}
