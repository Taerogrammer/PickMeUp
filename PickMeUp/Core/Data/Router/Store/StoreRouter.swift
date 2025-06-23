//
//  StoreRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

enum StoreRouter: APIRouter {
    case stores(query: StoreListRequest)
    case detail(query: StoreIDRequest)
    case like(query: StoreIDRequest, request: StoreLikeRequest)
    case search(query: StoreNameRequest)
    case popular
    case searchPopular
    case likedByMe

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .stores:
            return APIConstants.Endpoints.Store.stores
        case .detail(let request):
            return APIConstants.Endpoints.Store.detail(request.id)
        case .like(let request, _):
            return APIConstants.Endpoints.Store.like(request.id)
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
        case .like(_, let request):
            return [APIConstants.Parameters.Store.likeStatus: request.like_status]
        default:
            return nil
        }
    }

    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]

        if let token = KeychainManager.shared.load(key: KeychainType.refreshToken.rawValue) {
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
            if let category = query.category {
                items.append(.init(name: APIConstants.Query.Store.category, value: category))
            }
            if let lat = query.latitude {
                items.append(.init(name: APIConstants.Query.Store.latitude, value: "\(lat)"))
            }
            if let lng = query.longitude {
                items.append(.init(name: APIConstants.Query.Store.longitude, value: "\(lng)"))
            }
            if let next = query.next, !next.isEmpty {
                items.append(.init(name: APIConstants.Query.Store.next, value: next))
            }
            if let limit = query.limit {
                items.append(.init(name: APIConstants.Query.Store.limit, value: "\(limit)"))
            }
            items.append(.init(name: APIConstants.Query.Store.orderBy, value: query.orderBy.rawValue))
            return items

        case .detail(let request):
            return [.init(name: APIConstants.Query.Store.id, value: request.id)]

        case .like(let request):
            return [.init(name: APIConstants.Query.Store.id, value: request.query.id)]

        case .search(let request):
            return [.init(name: APIConstants.Query.Store.keyword, value: request.name)]

        case .popular:
            return [.init(name: APIConstants.Query.Store.limit, value: "10")]

        case .likedByMe:
            return [.init(name: APIConstants.Query.Store.page, value: "1")]

        case .searchPopular:
            return nil
        }
    }
}
