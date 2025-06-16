//
//  MeProfileRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

struct MeProfileRequest: Encodable {
    let nick: String
    let phoneNum: String
    let profileImage: String
}
