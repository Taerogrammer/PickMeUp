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

    func fetch<T: Decodable>(_ router: APIRouter, responseType: T.Type) async throws -> (statusCode: Int, response: T) {
        guard let urlRequest = router.urlRequest else { throw APIError.unknown }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
        return (statusCode: httpResponse.statusCode, response: decodedResponse)
    }
}
