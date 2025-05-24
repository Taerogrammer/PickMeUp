import Foundation

enum UserRouter: APIRouter {
    case validateEmail(email: String)
    case join(request: JoinRequest)
    case login(request: LoginRequest)
    case loginWithKakao(token: String)
    case loginWithApple(request: AppleLoginRequest)
    case getProfile
    
    var environment: APIEnvironment { .production }
    
    var path: String {
        switch self {
        case .validateEmail:
            return APIConstants.Endpoints.User.validateEmail
        case .join:
            return APIConstants.Endpoints.User.join
        case .login:
            return APIConstants.Endpoints.User.login
        case .loginWithKakao:
            return APIConstants.Endpoints.User.loginKakao
        case .loginWithApple:
            return APIConstants.Endpoints.User.loginApple
        case .getProfile:
            return APIConstants.Endpoints.User.profile
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .validateEmail, .join, .login, .loginWithKakao, .loginWithApple:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .validateEmail(let email):
            return [APIConstants.Parameters.email: email]
        case .join(let request):
            return [
                APIConstants.Parameters.email: request.email,
                APIConstants.Parameters.password: request.password,
                APIConstants.Parameters.nickname: request.nick,
                APIConstants.Parameters.phoneNumber: request.phoneNum,
                APIConstants.Parameters.deviceToken: request.deviceToken
            ]
        case .login(let request):
            return [
                APIConstants.Parameters.email: request.email,
                APIConstants.Parameters.password: request.password,
                APIConstants.Parameters.deviceToken: request.deviceToken
            ]
        case .loginWithKakao(let token):
            return [APIConstants.Parameters.token: token]
        case .loginWithApple(let request):
            return [
                APIConstants.Parameters.idToken: request.idToken,
                APIConstants.Parameters.deviceToken: request.deviceToken,
                APIConstants.Parameters.nickname: request.nick
            ]
        case .getProfile:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]
        
        switch self {
        case .validateEmail, .join, .login, .loginWithKakao, .loginWithApple:
            // 로그인 관련 요청은 Authorization 없음
            return baseHeaders
            
        default:
            // Authorization 헤더 추가
            if let refreshToken = TokenManager.shared.load(for: .refreshToken) {
                baseHeaders[APIConstants.Headers.authorization] = refreshToken
            } else {
                print(APIConstants.ErrorMessages.missingRefreshToken)
            }
            return baseHeaders
        }
    }
} 
