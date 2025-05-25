//
//  KakaoLoginRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import Foundation

struct KakaoLoginRequest: Encodable {
    let oauthToken: String
    let deviceToken: String
}
