//
//  RegisterView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {

            EmailVerificationField(viewModel: viewModel)

            ValidatedTextField(
                title: "Nickname",
                text: Binding(
                    get: { viewModel.state.nickname },
                    set: { viewModel.handleIntent(.updateNickname($0)) }
                ),
                message: viewModel.state.nicknameValidationMessage,
                isSuccess: viewModel.state.isNicknameValid
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if viewModel.state.isPasswordVisible {
                        TextField("Password", text: Binding(
                            get: { viewModel.state.password },
                            set: { viewModel.handleIntent(.updatePassword($0)) }
                        ))
                    } else {
                        SecureField("Password", text: Binding(
                            get: { viewModel.state.password },
                            set: { viewModel.handleIntent(.updatePassword($0)) }
                        ))
                    }

                    Button(action: {
                        viewModel.handleIntent(.togglePasswordVisibility)
                    }) {
                        Image(systemName: viewModel.state.isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Text(viewModel.state.passwordValidationMessage ?? " ")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: { viewModel.handleIntent(.submit) }) {
                Text("Register")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.state.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.state.isFormValid)

            Spacer()
        }
        .padding()
        .navigationTitle("회원가입")
        .scrollDismissesKeyboard(.interactively)
    }
}

struct EmailVerificationField: View {
    @ObservedObject var viewModel: RegisterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                TextField("Email", text: Binding(
                    get: { viewModel.state.email },
                    set: { viewModel.handleIntent(.updateEmail($0)) }
                ))
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 0, maxWidth: .infinity)
                .disabled(viewModel.state.isEmailValid)

                PrimaryButton(action: { viewModel.handleIntent(.validateEmail) }) {
                    Text("중복 확인")
                        .padding(.horizontal)
                }
                .fixedSize()
                .disabled(viewModel.state.isEmailValid)
            }

            Text(viewModel.state.emailValidationMessage ?? " ")
                .foregroundColor(viewModel.state.isEmailValid ? .green : .red)
                .font(.footnote)
        }
    }
}

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    let message: String?
    let isSuccess: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            Text(message ?? " ")
                .foregroundColor(isSuccess ? .green : .red)
                .font(.footnote)
        }
    }
}

#Preview {
    RegisterView(viewModel: RegisterViewModel(router: AppRouter()))
}
