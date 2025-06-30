//
//  PickMeUpApp.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI
import NMapsMap

@main
struct PickMeUpApp: App {
    @StateObject private var launchState = AppLaunchState()
    let container = DIContainer()

    init() {
        // 네이버 지도 SDK 초기화 (AppDelegate 방식과 동일한 효과)
        setupNaverMap()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .environmentObject(launchState)
        }
    }

    private func setupNaverMap() {
        // SecureKey-Info.plist에서 네이버 지도 클라이언트 ID 읽기
        let clientId = getSecureNaverMapClientId()

        guard !clientId.isEmpty else {
            print("❌ Naver Map Client ID is empty. Please check SecureKey-Info.plist")
            return
        }

        // 네이버 지도 SDK 초기화 (ncpKeyId 사용)
        NMFAuthManager.shared().ncpKeyId = clientId

        print("✅ NaverMap initialized successfully with Client ID: \(String(clientId.prefix(10)))...")
    }

    private func getSecureNaverMapClientId() -> String {
        guard let securePlistPath = Bundle.main.path(forResource: "SecureKey-Info", ofType: "plist"),
              let securePlist = NSDictionary(contentsOfFile: securePlistPath),
              let clientId = securePlist["Naver_Map_Client_ID"] as? String else {
            print("⚠️ SecureKey-Info.plist not found, trying APIEnvironment...")
            return APIEnvironment.production.naverClientID
        }

        return clientId
    }
}
