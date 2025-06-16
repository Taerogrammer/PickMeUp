//
//  APIErrorResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 5/12/25.
//

import Foundation

struct APIErrorResponse: Decodable {
    let code: Int
    let message: String
}
