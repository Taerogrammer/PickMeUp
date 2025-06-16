//
//  ProfileErrorView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI

struct ProfileErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("프로필을 불러올 수 없습니다")
                .font(.pretendardBody1)
                .foregroundColor(.gray75)

            Text(message)
                .font(.pretendardBody2)
                .foregroundColor(.gray60)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                onRetry()
            }
            .font(.pretendardBody1)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.deepSprout)
            .cornerRadius(8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
