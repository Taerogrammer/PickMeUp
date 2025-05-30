//
//  AuthViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

protocol AuthViewProviding {
    func makeLandingView(appLaunchState: AppLaunchState) -> AnyView
    func makeRegisterView() -> AnyView
}
