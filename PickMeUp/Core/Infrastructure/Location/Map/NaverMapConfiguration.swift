//
//  NaverMapConfiguration.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import Foundation
import NMapsMap

final class NaverMapConfiguration {
    static let shared = NaverMapConfiguration()

    private var isInitialized = false

    private init() {}

    /// 네이버 지도 SDK를 초기화합니다
    func initialize() {
        guard !isInitialized else {
            print("NaverMap already initialized")
            return
        }

        let clientId = loadClientId()

        guard !clientId.isEmpty else {
            print("❌ Naver Map Client ID is empty. Please check your configuration.")
            return
        }

        // 네이버 지도 SDK 초기화
        NMFAuthManager.shared().ncpKeyId = clientId
        isInitialized = true

        print("✅ NaverMap initialized successfully with Client ID: \(String(clientId.prefix(10)))...")
    }

    var isReady: Bool {
        guard let clientId = NMFAuthManager.shared().ncpKeyId else { return false }
        return !clientId.isEmpty
    }

    // MARK: - Private Methods

    private func loadClientId() -> String {
        if let secureClientId = loadFromSecurePlist() {
            return secureClientId
        }

        let apiClientId = APIEnvironment.production.naverClientID
        if !apiClientId.isEmpty {
            print("⚠️ Using fallback client ID from APIEnvironment")
            return apiClientId
        }

        return ""
    }

    private func loadFromSecurePlist() -> String? {
        guard let securePlistPath = Bundle.main.path(forResource: "SecureKey-Info", ofType: "plist"),
              let securePlist = NSDictionary(contentsOfFile: securePlistPath),
              let clientId = securePlist["Naver_Map_Client_ID"] as? String else {
            print("⚠️ SecureKey-Info.plist not found or invalid")
            return nil
        }

        return clientId
    }
}
