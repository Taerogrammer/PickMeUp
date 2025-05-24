import Foundation

enum APIConstants {
    // MARK: - Base URLs
    enum Environment {
        static let production = "https://api.sesac.com"
    }
    
    // MARK: - API Versions
    enum Version {
        static let v1 = "/v1"
    }
    
    // MARK: - Resource Paths
    enum Path {
        static let users = "users"
        static let auth = "auth"
        static let log = "log"
        
        enum Users {
            static let base = Version.v1 + "/" + Path.users
            static let me = base + "/me"
            static let validation = base + "/validation"
            static let login = base + "/login"
        }
        
        enum Auth {
            static let base = Version.v1 + "/" + Path.auth
        }
        
        enum Log {
            static let base = Version.v1 + "/" + Path.log
        }
    }
    
    // MARK: - Endpoints
    enum Endpoints {
        // Auth
        enum Auth {
            static let refresh = Path.Auth.base + "/refresh"
        }
        
        // User
        enum User {
            static let validateEmail = Path.Users.validation + "/email"
            static let join = Path.Users.base + "/join"
            static let login = Path.Users.login
            static let loginKakao = Path.Users.login + "/kakao"
            static let loginApple = Path.Users.login + "/apple"
            static let profile = Path.Users.me + "/profile"
        }
        
        // Log
        enum Log {
            static let create = Path.Log.base
        }
    }
    
    // MARK: - Headers
    enum Headers {
        static let sesacKey = "SeSACKey"
        static let authorization = "Authorization"
        
        // Header Values
        enum Values {
            static func sesacKeyValue() -> String {
                Bundle.value(forKey: "SeSACKey")
            }
        }
    }
    
    // MARK: - Parameters
    enum Parameters {
        static let email = "email"
        static let password = "password"
        static let nickname = "nick"
        static let phoneNumber = "phoneNum"
        static let deviceToken = "deviceToken"
        static let token = "token"
        static let key = "key"
    }
    
    // MARK: - Error Messages
    enum ErrorMessages {
        static let missingRefreshToken = "⚠️ RefreshToken이 없습니다. Authorization 헤더가 누락됩니다."
    }
} 
