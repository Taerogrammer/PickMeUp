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

    func request<T: Decodable>(_ router: APIRouter, responseType: T.Type) async throws -> T {
        guard let urlRequest = router.urlRequest else { throw APIError.unknown }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(T.self, from: data)
        }

        if let errorResponse = try? JSONDecoder().decode(CommonMessageResponse.self, from: data) {
            throw APIError.serverMessage(errorResponse.message)
        }

        throw APIError.unknown
    }
}
