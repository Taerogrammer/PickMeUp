//
//  ValidatedTextField.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ValidatedTextField: View {
    let title: String
    let text: String
    let message: String?
    let isSuccess: Bool
    let onChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: Binding<String>(
                get: { text },
                set: { onChange($0) }
            ))
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)

            Text(message ?? " ")
                .foregroundColor(isSuccess ? .green : .red)
                .font(.footnote)
        }
    }
}
