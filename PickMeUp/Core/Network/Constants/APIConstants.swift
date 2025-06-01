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
        static let log = "/log"
        static let auth = "/auth"
        static let users = "/users"
        static let stores = "/stores"
        static let chat = "/chats"

        enum Log {
            static let base = Version.v1 + Path.log
        }

        enum Auth {
            static let base = Version.v1 + Path.auth
        }

        enum Users {
            static let base = Version.v1 + Path.users
            static let me = base + "/me"
            static let validation = base + "/validation"
            static let login = base + "/login"
        }

        enum Store {
            static let base = Version.v1 + Path.stores
        }

        enum Chat {
            static let base = Version.v1 + Path.chat
            static func room(_ id: String) -> String { base + "/\(id)" }
            static func files(_ id: String) -> String { room(id) + "/files" }
        }
    }
    
    // MARK: - Endpoints
    enum Endpoints {

        /// Log
        enum Log {
            static let create = Path.Log.base
        }

        /// Auth
        enum Auth {
            static let refresh = Path.Auth.base + "/refresh"
        }
        
        /// User
        enum User {
            static let validateEmail = Path.Users.validation + "/email"
            static let join = Path.Users.base + "/join"
            static let login = Path.Users.login
            static let loginKakao = Path.Users.login + "/kakao"
            static let loginApple = Path.Users.login + "/apple"
            static let profile = Path.Users.me + "/profile"
            static let profileImage = Path.Users.base + "/profile" + "/image"
        }

        /// Store
        enum Store {
            static let stores = Path.Store.base
            static func detail(_ id: String) -> String { Path.Store.base + "/\(id)" }
            static func like(_ id: String) -> String { Path.Store.base + "/\(id)/like" }
            static let search = Path.Store.base + "/search"
            static let popular = Path.Store.base + "/popular-stores"
            static let searchPopular = Path.Store.base + "/searches-popular"
            static let likedByMe = Path.Store.base + "/likes/me"
        }

        /// Chat
        enum Chat {
            static let chat = Path.Chat.base
            static func chatting(_ roomID: String) -> String { Path.Chat.room(roomID) }
            static func files(_ roomID: String) -> String { Path.Chat.files(roomID) }
        }
    }
    
    // MARK: - Headers
    enum Headers {
        static let sesacKey = "SeSACKey"
        static let authorization = "Authorization"
        static let refreshToken = "RefreshToken"
        static let accept = "accept"

        enum Values {
            static func sesacKeyValue() -> String {
                Bundle.value(forKey: "SeSACKey")
            }

            static let applicationJson = "application/json"
            static let multipartFormData = "multipart/form-data"
        }
    }
    
    // MARK: - Parameters
    enum Parameters {

        enum Log {
            static let key = "key"
        }

        enum User {
            static let email = "email"
            static let password = "password"
            static let nickname = "nick"
            static let phoneNumber = "phoneNum"
            static let deviceToken = "deviceToken"
            static let idToken = "idToken"
            static let oauthToken = "oauthToken"
            static let profileImage = "profileImage"
        }

        enum Chat {
            static let opponentID = "opponent_id"
            static let content = "content"
            static let files = "files"
        }
    }



    // MARK: - Error Messages
    enum ErrorMessages {
        static let missingRefreshToken = "⚠️ RefreshToken이 없습니다. Authorization 헤더가 누락됩니다."
    }
} 
