import Foundation

enum AuthRouter: APIRouter {
    case refreshToken
    
    var environment: APIEnvironment { .production }
    
    var path: String {
        switch self {
        case .refreshToken:
            return APIConstants.Endpoints.Auth.refresh
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .refreshToken:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .refreshToken:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.accept: APIConstants.Headers.Values.applicationJson,
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue(),
            APIConstants.Headers.refreshToken: KeychainManager.shared.load(key: KeychainType.refreshToken.rawValue) ?? ""
            // MARK: - 로그인 실패
//            APIConstants.Headers.refreshToken: ""
        ]
        
        // Authorization 헤더 추가
        if let refreshToken = KeychainManager.shared.load(key: KeychainType.refreshToken.rawValue) {
            baseHeaders[APIConstants.Headers.authorization] = refreshToken
        } else {
            print(APIConstants.ErrorMessages.missingRefreshToken)
        }
        return baseHeaders
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}
