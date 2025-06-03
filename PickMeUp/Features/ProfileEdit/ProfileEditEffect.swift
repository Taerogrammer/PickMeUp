//
//  ProfileEditEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

// TODO: - 이미지 형식 맞추기 (png, jpg, jpeg 이회의 이미지도 가능하게끔)
struct ProfileEditEffect {
    func saveProfile(profile: ProfileEntity) async -> Result<MeProfileResponse, APIError> {
        do {
            let request = profile.toRequest()
            let result = try await NetworkManager.shared.fetch(
                UserRouter.putProfile(request: request),
                successType: MeProfileResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                return .success(success)
            } else if let failure = result.failure {
                return .failure(.message(failure.message))
            } else {
                return .failure(.unknown)
            }
        } catch {
            return .failure(.message(error.localizedDescription))
        }
    }

    func uploadImage(_ image: UIImage) async -> Result<String, APIError> {
        let imageData: Data
        let filename: String
        let mimeType: String

        // 서버가 지원하지 않는 포맷을 방지하기 위해 무조건 변환
        if image.isPNG {
            imageData = image.pngData()!
            filename = "profile.png"
            mimeType = "image/png"
        } else {
            imageData = image.jpegData(compressionQuality: 0.8)!
            filename = "profile.jpg"
            mimeType = "image/jpeg"
        }

        let requestData = ProfileImageRequest(
            imageData: imageData,
            fileName: filename,
            mimeType: mimeType
        )

        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.uploadProfileImage(request: requestData),
                successType: ProfileImageResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                return .success(success.profileImage)
            } else if let failure = result.failure {
                return .failure(.message(failure.message))
            } else {
                return .failure(.unknown)
            }
        } catch {
            return .failure(.message("이미지 업로드 실패: \(error.localizedDescription)"))
        }
    }

    func loadRemoteImage(for path: String?, store: ProfileEditStore) {
        guard let path = path else {
            store.send(.loadRemoteImageFailed("이미지 경로가 존재하지 않습니다"))
            return
        }

        ImageLoader.load(
            from: path,
            accessTokenKey: "accessToken",
            responder: store
        )
    }
}

extension UIImage {
    func inferredFormat() -> ImageFormat {
        if let data = self.pngData(), data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return .png
        } else {
            return .jpeg
        }
    }

    var isPNG: Bool {
        guard let data = self.pngData() else { return false }
        return data.starts(with: [0x89, 0x50, 0x4E, 0x47])
    }

    var isJPEG: Bool {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return false }
        return data.starts(with: [0xFF, 0xD8])
    }
}
