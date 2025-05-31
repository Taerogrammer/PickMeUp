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
        guard let urlRequest = router.urlRequest else {
            throw APIError.unknown
        }

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

    func debugCurlWithResponse(
        request: URLRequest,
        response: URLResponse?,
        data: Data?
    ) {
        print("📡 [cURL 요청]")
        print(request.curlString)

        if let httpResponse = response as? HTTPURLResponse {
            print("\n📩 [응답 상태 코드]: \(httpResponse.statusCode)")
            print("📩 [응답 헤더]:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("  \(key): \(value)")
            }
        }

        if let data = data,
           let body = String(data: data, encoding: .utf8) {
            print("📦 [응답 바디]:\n\(body)")
        }
    }
}

extension URLRequest {
    var curlString: String {
        var components = ["curl -X \(httpMethod ?? "GET")"]

        if let url = url {
            components.append("\"\(url.absoluteString)\"")
        }

        allHTTPHeaderFields?.forEach { key, value in
            components.append("-H \"\(key): \(value)\"")
        }

        if let httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }

        return components.joined(separator: " \\\n\t")
    }
}
