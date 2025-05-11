//
//  APIEnvironment.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum APIEnvironment {
    case production

    var baseURL: String {
        switch self {
        case .production:
            return Bundle.value(forKey: "BASE_URL")
        }
    }
}
