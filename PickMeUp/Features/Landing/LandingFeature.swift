//
//  LandingReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import ComposableArchitecture

@Reducer
struct LandingFeature {

    @ObservableState
    struct State: Equatable {}

    enum Action {
        case appleLoginTapped
        case googleLoginTapped
        case kakaoLoginTapped
        case naverLoginTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appleLoginTapped:
                print("Apple 로그인 시도")
                return .none
            case .googleLoginTapped:
                print("Google 로그인 시도")
                return .none
            case .kakaoLoginTapped:
                print("Kakao 로그인 시도")
                return .none
            case .naverLoginTapped:
                print("Naver 로그인 시도")
                return .none
            }
        }
    }
}
