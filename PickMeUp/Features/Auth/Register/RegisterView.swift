//
//  RegisterView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var store: RegisterStore

    init(store: RegisterStore) {
        _store = StateObject(wrappedValue: store)
    }

    public var body: some View {
        VStack(spacing: 16) {
            EmailVerificationField(state: store.state) { intent in
                store.send(intent)
            }

            ValidatedTextField(
                title: "Nickname",
                text: store.state.nickname,
                message: store.state.nicknameValidationMessage,
                isSuccess: store.state.isNicknameValid,
                onChange: { store.send(.updateNickname($0)) }
            )

            PasswordField(
                title: "Password",
                text: store.state.password,
                isPasswordVisible: store.state.isPasswordVisible,
                validationMessage: store.state.passwordValidationMessage,
                onChange: { store.send(.updatePassword($0)) },
                onToggleVisibility: { store.send(.togglePasswordVisibility) }
            )

            Button(action: {
                store.send(.submit)
            }) {
                Text("Register")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(store.state.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!store.state.isFormValid)

            Spacer()
        }
        .padding()
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    RegisterView(store: RegisterStore(router: AppRouter()))
}
