//
//  PickupRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum PickupRouter: APIRouter {

    // 공통사항
    case getCommon

    // 인증
    case refreshToken

    // 사용자
    case validateEmail(email: String)
    case join(email: String, password: String)
    case login(email: String, password: String)
    case loginWithKakao(token: String)
    case loginWithApple(token: String)
    case getProfile

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .getCommon:
            return "/common"
        case .refreshToken:
            return "/v1/auth/refresh"
        case .validateEmail:
            return "/v1/users/validation/email"
        case .join:
            return "/v1/users/join"
        case .login:
            return "/v1/users/login"
        case .loginWithKakao:
            return "/v1/users/login/kakao"
        case .loginWithApple:
            return "/v1/users/login/apple"
        case .getProfile:
            return "/v1/users/me/profile"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getCommon, .refreshToken, .getProfile:
            return .get
        case .validateEmail, .join, .login, .loginWithKakao, .loginWithApple:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .validateEmail(let email):
            return ["email": email]
        case .join(let email, let password):
            return ["email": email, "password": password]
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .loginWithKakao(let token), .loginWithApple(let token):
            return ["token": token]
        default:
            return nil
        }
    }

    var headers: [String: String]? {
        ["SeSACKey": Bundle.value(forKey: "SeSACKey")]
    }
}
