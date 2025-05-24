import Foundation

enum LogRouter: APIRouter {
    case log(key: String)
    
    var environment: APIEnvironment { .production }
    
    var path: String {
        switch self {
        case .log:
            return APIConstants.Endpoints.Log.create
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .log:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .log(let key):
            return [APIConstants.Parameters.key: key]
        }
    }
    
    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]
        
        // Authorization 헤더 추가
        if let refreshToken = TokenManager.shared.load(for: .refreshToken) {
            baseHeaders[APIConstants.Headers.authorization] = refreshToken
        } else {
            print(APIConstants.ErrorMessages.missingRefreshToken)
        }
        return baseHeaders
    }
} 