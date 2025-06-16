//
//  EmailVerificationField.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct EmailVerificationField: View {
    let state: RegisterState
    let onSend: (RegisterAction.Intent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                TextField("Email", text: Binding(
                    get: { state.email },
                    set: { onSend(.updateEmail($0)) }
                ))
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 0, maxWidth: .infinity)
                .disabled(state.isEmailValid)

                PrimaryButton(action: { onSend(.validateEmail) }) {
                    Text("중복 확인")
                        .padding(.horizontal)
                }
                .fixedSize()
                .disabled(state.isEmailValid)
            }

            Text(state.emailValidationMessage ?? " ")
                .foregroundColor(state.isEmailValid ? .green : .red)
                .font(.footnote)
        }
    }
}
