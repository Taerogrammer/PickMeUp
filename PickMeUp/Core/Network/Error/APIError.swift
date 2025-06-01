//
//  APIError.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

enum APIError: Error {
    case message(String)
    case unknown

    var message: String {
        switch self {
        case .message(let msg): return msg
        case .unknown: return "알 수 없는 오류가 발생했습니다"
        }
    }
}
