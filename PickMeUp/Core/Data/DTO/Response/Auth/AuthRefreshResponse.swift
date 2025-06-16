//
//  AuthRefreshResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

struct AuthRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
