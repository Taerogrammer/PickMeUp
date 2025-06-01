//
//  AppleLoginRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 5/24/25.
//

import Foundation

struct AppleLoginRequest: Encodable {
    let idToken: String
    let deviceToken: String
    var nick: String
}
