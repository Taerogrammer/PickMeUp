//
//  JoinRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 5/12/25.
//

import Foundation


struct JoinRequest: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String
    let deviceToken: String
}
