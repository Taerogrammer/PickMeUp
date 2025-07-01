//
//  NaverGeocodingError.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

// MARK: - 에러 정의
enum NaverGeocodingError: LocalizedError {
    case invalidQuery
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case serverError(Int)
    case apiError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "잘못된 검색어입니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .unauthorized:
            return "API 인증에 실패했습니다. API 키를 확인해주세요."
        case .rateLimitExceeded:
            return "API 호출 한도를 초과했습니다. 잠시 후 다시 시도해주세요."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .apiError(let message):
            return "API 오류: \(message)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
