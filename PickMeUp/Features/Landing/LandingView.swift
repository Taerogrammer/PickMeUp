//
//  LandingView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import ComposableArchitecture

struct LandingView: View {
    @Bindable var store: StoreOf<LandingFeature>

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Pick Me Up")
                .font(.jalnanTitle1)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(action: { store.send(.appleLoginTapped) }) {
                    Text("Sign in with Apple")
                }

                PrimaryButton(action: { store.send(.googleLoginTapped) }) {
                    Text("Sign in with Google")
                }

                PrimaryButton(action: { store.send(.kakaoLoginTapped) }) {
                    Text("Sign in with Kakao")
                }

                PrimaryButton(action: { store.send(.naverLoginTapped) }) {
                    Text("Sign in with Naver")
                }
            }

            Spacer()
        }
        .background(Color(white: 0.95).ignoresSafeArea())
    }
}

#Preview {
    LandingView(store: Store(
        initialState: LandingFeature.State(),
        reducer: { LandingFeature() }
    ))
}
