//
//  ProfileEditEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

// TODO: - 이미지 형식 맞추기 (png, jpg, jpeg 이회의 이미지도 가능하게끔)
struct ProfileEditEffect {
    func handle(_ intent: ProfileEditAction.Intent, store: ProfileEditStore) {
        switch intent {
        case .saveTapped:
            store.handleSaveTapped()
        case .uploadImage:
            store.handleUploadImage()
        default:
            break
        }
    }

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
