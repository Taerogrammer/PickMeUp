//
//  AppLaunchState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

final class AppLaunchState: ObservableObject {
    @Published var isSessionValid: Bool = false
    @Published var didCheckSession: Bool = false
}
