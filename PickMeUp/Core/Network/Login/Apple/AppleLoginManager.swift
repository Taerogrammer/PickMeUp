//
//  AppleLoginManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/24/25.
//

import Foundation
import AuthenticationServices

final class AppleLoginManager: NSObject {
    static let shared = AppleLoginManager()

    private var continuation: CheckedContinuation<AppleLoginRequest, Error>?
    private var deviceToken: String = ""

    func setDeviceToken(_ token: String) {
        self.deviceToken = token
    }

    func login() async throws -> AppleLoginRequest {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            continuation?.resume(throwing: NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID 토큰이 유효하지 않습니다."]))
            return
        }

        let nickname = [credential.fullName?.familyName, credential.fullName?.givenName]
            .compactMap { $0 }
            .joined()

        print("🔐 [AppleLogin] idToken: \(idToken)")
        print("📱 [AppleLogin] deviceToken: \(deviceToken)")
        print("🪪 [AppleLogin] user: \(credential.user)")

        let request = AppleLoginRequest(idToken: idToken, deviceToken: deviceToken, nick: nickname.isEmpty ? credential.user : nickname)
        continuation?.resume(returning: request)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
