//
//  StoreRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

enum StoreRouter: APIRouter {
    case stores(query: StoreListRequest)
    case detail(id: String)
    case like(id: String)
    case search(name: String)
    case popular
    case searchPopular
    case likedByMe

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .stores:
            return APIConstants.Endpoints.Store.stores
        case .detail(let id):
            return APIConstants.Endpoints.Store.detail(id)
        case .like(let id):
            return APIConstants.Endpoints.Store.like(id)
        case .search:
            return APIConstants.Endpoints.Store.search
        case .popular:
            return APIConstants.Endpoints.Store.popular
        case .searchPopular:
            return APIConstants.Endpoints.Store.searchPopular
        case .likedByMe:
            return APIConstants.Endpoints.Store.likedByMe
        }
    }

    var method: HTTPMethod {
        switch self {
        case .stores, .detail, .search, .popular, .searchPopular, .likedByMe:
            return .get
        case .like:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .stores:
            return nil
        case .search:
            return nil
        default:
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
        switch self {
        case .stores(let query):
            var items: [URLQueryItem] = []
            if let category = query.category { items.append(.init(name: "category", value: category)) }
            if let lat = query.latitude { items.append(.init(name: "latitude", value: "\(lat)")) }
            if let lng = query.longitude { items.append(.init(name: "longitude", value: "\(lng)")) }
            if let next = query.next, !next.isEmpty { items.append(.init(name: "next", value: next)) }
            if let limit = query.limit { items.append(.init(name: "limit", value: "\(limit)")) }
            items.append(.init(name: "order_by", value: query.orderBy.rawValue))
            return items

        case .detail(let id):
            return [URLQueryItem(name: "id", value: id)]

        case .like(let id):
            return [URLQueryItem(name: "id", value: id)]

        case .search(let name):
            return [URLQueryItem(name: "keyword", value: name)]

        case .popular:
            return [URLQueryItem(name: "limit", value: "10")] // 필요시 수정

        case .searchPopular:
            return nil

        case .likedByMe:
            return [URLQueryItem(name: "page", value: "1")] // 필요시 수정
        }
    }
}
