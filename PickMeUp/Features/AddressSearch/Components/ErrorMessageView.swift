//
//  ErrorMessageView.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

// MARK: - 에러 메시지 뷰
struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.brightForsythia)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.blackSprout)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(.gray45)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brightForsythia.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.brightForsythia.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
