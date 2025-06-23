import Foundation

enum UserRouter: APIRouter {
    case validateEmail(request: EmailRequest)
    case join(request: JoinRequest)
    case login(request: LoginRequest)
    case loginWithKakao(request: KakaoLoginRequest)
    case loginWithApple(request: AppleLoginRequest)
    case getProfile
    case putProfile(request: MeProfileRequest)
    case uploadProfileImage(request: ProfileImageRequest)

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
        case .getProfile, .putProfile:
            return APIConstants.Endpoints.User.profile
        case .uploadProfileImage:
            return APIConstants.Endpoints.User.profileImage
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .putProfile:
            return .put
        default:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .validateEmail(let request):
            return [APIConstants.Parameters.User.email: request.email]
        case .join(let request):
            return [
                APIConstants.Parameters.User.email: request.email,
                APIConstants.Parameters.User.password: request.password,
                APIConstants.Parameters.User.nickname: request.nick,
                APIConstants.Parameters.User.phoneNumber: request.phoneNum,
                APIConstants.Parameters.User.deviceToken: request.deviceToken
            ]
        case .login(let request):
            return [
                APIConstants.Parameters.User.email: request.email,
                APIConstants.Parameters.User.password: request.password,
                APIConstants.Parameters.User.deviceToken: request.deviceToken
            ]
        case .loginWithKakao(let request):
            return [
                APIConstants.Parameters.User.oauthToken: request.oauthToken,
                APIConstants.Parameters.User.deviceToken: request.deviceToken
            ]
        case .loginWithApple(let request):
            return [
                APIConstants.Parameters.User.idToken: request.idToken,
                APIConstants.Parameters.User.deviceToken: request.deviceToken,
                APIConstants.Parameters.User.nickname: request.nick
            ]
        case .putProfile(let request):
            return [
                APIConstants.Parameters.User.nickname: request.nick,
                APIConstants.Parameters.User.phoneNumber: request.phoneNum,
                APIConstants.Parameters.User.profileImage: request.profileImage
            ]
        case .getProfile, .uploadProfileImage:
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
            if let refreshToken = KeychainManager.shared.load(key: KeychainType.refreshToken.rawValue) {
                baseHeaders[APIConstants.Headers.authorization] = refreshToken
                baseHeaders["Content-Type"] = "multipart/form-data; boundary=\(UUID().uuidString)"
            } else {
                print(APIConstants.ErrorMessages.missingRefreshToken)
            }
            return baseHeaders

        default:
            if let refreshToken = KeychainManager.shared.load(key: KeychainType.refreshToken.rawValue) {
                baseHeaders[APIConstants.Headers.authorization] = refreshToken
            } else {
                print(APIConstants.ErrorMessages.missingRefreshToken)
            }
            return baseHeaders
        }
    }

    var queryItems: [URLQueryItem]? { nil }

    var urlRequest: URLRequest? {
        guard let baseURL = URL(string: environment.baseURL) else { return nil }
        let fullURL = baseURL.appendingPathComponent(path)
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .uploadProfileImage(let profileImageRequest):
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

            let imageData = profileImageRequest.imageData
            let fileName = profileImageRequest.fileName
            let mimeType = profileImageRequest.mimeType
            let fieldName = "profile"

            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            urlRequest.httpBody = body
            return urlRequest

        default:
            if let parameters = parameters {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
            headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
            return urlRequest
        }
    }
}
