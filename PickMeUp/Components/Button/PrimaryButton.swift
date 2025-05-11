//
//  PrimaryButton.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct PrimaryButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: action) {
            content()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                .background(Color.black)
                .cornerRadius(8)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack {
        PrimaryButton(action: {
            print("Tapped")
        }) {
            HStack {
                Image("apple")
                Text("Sign in with Apple")
            }
        }

        PrimaryButton(action: {
            print("Tapped")
        }) {
            HStack {
                Image("kakao_login_button")
                    .resizable()
            }
        }
    }
}
