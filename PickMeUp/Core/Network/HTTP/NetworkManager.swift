//
//  RequestManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    /// 상태 코드에 따라 성공/실패를 구분해 디코딩
    func fetch<Success: Decodable, Failure: Decodable>(
        _ router: APIRouter,
        successType: Success.Type,
        failureType: Failure.Type
    ) async throws -> (statusCode: Int, success: Success?, failure: Failure?) {
        guard let urlRequest = router.urlRequest else { throw APIError.unknown }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        let statusCode = httpResponse.statusCode

        if (200...299).contains(statusCode) {
            let decodedSuccess = try? JSONDecoder().decode(Success.self, from: data)
            return (statusCode, decodedSuccess, nil)
        } else {
            let decodedFailure = try? JSONDecoder().decode(Failure.self, from: data)
            return (statusCode, nil, decodedFailure)
        }
    }
}
