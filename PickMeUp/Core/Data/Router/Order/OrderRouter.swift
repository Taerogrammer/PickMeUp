//
//  OrderRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/8/25.
//

import Foundation

enum OrderRouter: APIRouter {
    case submitOrder(request: OrderRequest)
    case orderHistory
    case orderChange(request: OrderChangeRequest)

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .submitOrder:
            return APIConstants.Endpoints.Order.order
        case .orderHistory:
            return APIConstants.Endpoints.Order.order
        case .orderChange(let request):
            return APIConstants.Endpoints.Order.orderChange(request.orderCode)
        }
    }

    var method: HTTPMethod {
        switch self {
        case .submitOrder:
            return .post
        case .orderHistory:
            return .get
        case .orderChange:
            return .put
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
        case .orderHistory:
            return nil
        case .orderChange(request: let request):
            return [APIConstants.Parameters.Order.nextStatus: request.nextStatus]
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
        case .submitOrder, .orderHistory, .orderChange:
            return nil
        }
    }
}
