//
//  ProfileEditEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

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

    func uploadImage(_ image: UIImage, format: ImageFormat) async -> Result<String, APIError> {
        let imageData: Data?
        var filename: String
        var mimeType: String

        switch format {
        case .jpeg, .jpg:
            imageData = image.jpegData(compressionQuality: 0.8)
            filename = "profile.jpg"
            mimeType = "image/jpeg"
        case .png:
            imageData = image.pngData()
            filename = "profile.png"
            mimeType = "image/png"
        }

        guard let data = imageData else {
            return .failure(.message("이미지 데이터를 생성할 수 없습니다."))
        }

        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.uploadProfileImage(imageData: data, fileName: filename, mimeType: mimeType),
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
}
