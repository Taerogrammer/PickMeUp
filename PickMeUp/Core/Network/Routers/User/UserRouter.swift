import Foundation

enum UserRouter: APIRouter {
    case validateEmail(email: String)
    case join(request: JoinRequest)
    case login(request: LoginRequest)
    case loginWithKakao(request: KakaoLoginRequest)
    case loginWithApple(request: AppleLoginRequest)
    case getProfile
    case putProfile(request: MeProfileRequest)
    case uploadProfileImage(imageData: Data, fileName: String, mimeType: String)

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
        case .putProfile:
            return APIConstants.Endpoints.User.profile
        case .uploadProfileImage:
            return APIConstants.Endpoints.User.profileImage
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .validateEmail, .join, .login, .loginWithKakao, .loginWithApple, .uploadProfileImage:
            return .post
        case .putProfile:
            return .put
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
        case .loginWithKakao(let request):
            return [
                APIConstants.Parameters.oauthToken: request.oauthToken,
                APIConstants.Parameters.deviceToken: request.deviceToken
            ]
        case .loginWithApple(let request):
            return [
                APIConstants.Parameters.idToken: request.idToken,
                APIConstants.Parameters.deviceToken: request.deviceToken,
                APIConstants.Parameters.nickname: request.nick
            ]
        case .getProfile:
            return nil
        case .putProfile(let request):
            return [
                APIConstants.Parameters.nickname: request.nick,
                APIConstants.Parameters.phoneNumber: request.phoneNum,
                APIConstants.Parameters.profileImage: request.profileImage
            ]
        case .uploadProfileImage:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]
        switch self {
        case .validateEmail, .join, .login, .loginWithKakao, .loginWithApple:
            return baseHeaders

        case .uploadProfileImage:
            if let refreshToken = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) {
                baseHeaders[APIConstants.Headers.authorization] = refreshToken

                // boundary 생성
                let boundary = UUID().uuidString
                baseHeaders["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            } else {
                print(APIConstants.ErrorMessages.missingRefreshToken)
            }
            return baseHeaders

        default:
            if let refreshToken = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) {
                baseHeaders[APIConstants.Headers.authorization] = refreshToken
            } else {
                print(APIConstants.ErrorMessages.missingRefreshToken)
            }
            return baseHeaders
        }
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}

// MARK: - URLRequest 구성 확장 추가
extension UserRouter {
    var urlRequest: URLRequest? {
        guard let baseURL = URL(string: environment.baseURL) else { return nil }
        let fullURL = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: fullURL)
        request.httpMethod = method.rawValue

        switch self {
        case .uploadProfileImage(let imageData, let fileName, let mimeType):
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            // 헤더 추가
            headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

            // multipart body 구성
            var body = Data()
            let fieldName = "profile"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body
            return request

        default:
            // JSON 기반 요청 처리
            if let parameters = parameters {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
            headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
            return request
        }
    }
}
