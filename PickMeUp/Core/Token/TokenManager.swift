import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let userDefaults = UserDefaults.standard

    // 토큰 저장
    func save(_ token: String, for type: TokenType) {
        userDefaults.set(token, forKey: type.rawValue)
    }

    // 토큰 불러오기
    func load(for type: TokenType) -> String? {
        userDefaults.string(forKey: type.rawValue)
    }

    // 토큰 삭제
    func remove(for type: TokenType) {
        userDefaults.removeObject(forKey: type.rawValue)
    }

    func printStoredTokens() {
        let access = load(for: .accessToken) ?? "(없음)"
        let refresh = load(for: .refreshToken) ?? "(없음)"

        print("🔐 [TokenManager] 저장된 토큰 정보:")
        print("  - Access Token: \(access)")
        print("  - Refresh Token: \(refresh)")
    }

//    // 모든 토큰 삭제
//    func clearAll() {
//        TokenType.allCases.forEach { remove(for: $0) }
//    }

}
