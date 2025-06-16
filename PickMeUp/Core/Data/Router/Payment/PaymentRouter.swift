//
//  PaymentRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

enum PaymentRouter: APIRouter {
    case verify(request: PaymentValidationRequest)
    case detail(orderCode: String)

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .verify:
            return APIConstants.Endpoints.Payment.validation
        case .detail(let orderCode):
            return APIConstants.Endpoints.Payment.detail(orderCode)
        }
    }

    var method: HTTPMethod {
        switch self {
        case .verify:
            return .post
        case .detail:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .verify(let request):
            return [
                APIConstants.Parameters.Payment.impUID: request.imp_uid
            ]
        case .detail:
            return nil
        }
    }

    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]

        if let token = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) {
            baseHeaders[APIConstants.Headers.authorization] = token
        } else {
            print(APIConstants.ErrorMessages.missingRefreshToken)
        }

        return baseHeaders
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}
