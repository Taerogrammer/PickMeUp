//
//  AuthManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func validateSession() async -> Bool {
        guard let refreshToken = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) else {
            print("❌ [AuthService] 리프레시 토큰이 없습니다.")
            return false
        }

        do {
            let response = try await NetworkManager.shared.fetch(
                AuthRouter.refreshToken,
                successType: AuthRefreshResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = response.success {
                print("✅ [AuthService] 세션 유효. accessToken 갱신됨.")
                KeychainManager.shared.save(key: TokenType.accessToken.rawValue, value: success.accessToken)
                KeychainManager.shared.save(key: TokenType.refreshToken.rawValue, value: success.refreshToken)
                return true
            } else {
                print("❌ [AuthService] 세션 만료: \(response.statusCode) \(response.failure?.message ?? "알 수 없는 오류")")
                return false
            }
        } catch {
            print("❌ [AuthService] API 실패: \(error.localizedDescription)")
            return false
        }
    }
}
