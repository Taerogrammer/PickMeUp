//
//  OrderRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/8/25.
//

import Foundation

enum OrderRouter: APIRouter {
    case submitOrder(request: OrderRequest)

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .submitOrder:
            return APIConstants.Endpoints.Order.submit
        }
    }

    var method: HTTPMethod {
        switch self {
        case .submitOrder:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .submitOrder(let request):
            return [
                APIConstants.Parameters.Order.storeID: request.store_id,
                APIConstants.Parameters.Order.orderMenuList: request.order_menu_list.map { menuItem in
                    [
                        APIConstants.Parameters.Order.menuID: menuItem.menu_id,
                        APIConstants.Parameters.Order.quantity: menuItem.quantity
                    ]
                },
                APIConstants.Parameters.Order.totalPrice: request.total_price
            ]
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
        switch self {
        case .submitOrder:
            return nil
        }
    }
}
