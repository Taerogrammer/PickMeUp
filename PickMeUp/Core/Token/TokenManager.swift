//
//  TokenManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/13/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    // MARK: - 메모리 캐시 (AccessToken 전용)
    private var accessTokenCache: String?

    // MARK: - Save
    func save(_ value: String, for type: TokenType) {
        switch type {
        case .accessToken:
            accessTokenCache = value  // 메모리에만 저장
        case .refreshToken, .deviceToken:
            KeychainManager.shared.save(key: type.rawValue, value: value)
        }
    }

    // MARK: - Load
    func load(for type: TokenType) -> String? {
        switch type {
        case .accessToken:
            return accessTokenCache
        case .refreshToken, .deviceToken:
            return KeychainManager.shared.load(key: type.rawValue)
        }
    }

    // MARK: - Delete
    func clear(for type: TokenType) {
        switch type {
        case .accessToken:
            accessTokenCache = nil
        case .refreshToken, .deviceToken:
            KeychainManager.shared.delete(key: type.rawValue)
        }
    }

    // MARK: - 전체 삭제
    func clearAll() {
        accessTokenCache = nil
        KeychainManager.shared.delete(key: TokenType.refreshToken.rawValue)
        KeychainManager.shared.delete(key: TokenType.deviceToken.rawValue)
    }

    func printStoredTokens() {
        let accessToken = accessTokenCache ?? "없음"
        let refreshToken = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) ?? "없음"

        print("[DEBUG] AccessToken: \(accessToken)")
        print("[DEBUG] RefreshToken: \(refreshToken)")
    }
}
