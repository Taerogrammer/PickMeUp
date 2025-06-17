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
    ) async throws -> (statusCode: Int, success: Success?, failure: Failure?, isFromCache: Bool) {
        guard let urlRequest = router.urlRequest else {
            throw APIError.unknown
        }

        let delegate = TaskDelegate()
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

        let (data, response) = try await session.data(for: urlRequest)

//        print("[HTTP Request + Response]")
//        debugFullResponse(request: urlRequest, response: response, data: data)

        let isFromCache = checkCacheStatus(metrics: delegate.lastMetrics)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        let statusCode = httpResponse.statusCode

        if (200...299).contains(statusCode) {
            let decodedSuccess = try? JSONDecoder().decode(Success.self, from: data)
            return (statusCode, decodedSuccess, nil, isFromCache)
        } else {
            let decodedFailure = try? JSONDecoder().decode(Failure.self, from: data)
            return (statusCode, nil, decodedFailure, isFromCache)
        }
    }

    @discardableResult
    private func checkCacheStatus(metrics: URLSessionTaskMetrics?) -> Bool {
        guard let metrics = metrics,
              let firstTransaction = metrics.transactionMetrics.first else {
            return false
        }

        switch firstTransaction.resourceFetchType {
        case .localCache:
//            print("💾 [캐시]: 서버에서 304 응답 → URLSession이 캐시 사용")
            return true
        case .networkLoad:
//            print("🌐 [네트워크]: 서버에서 새로 로드됨")
            return false
        default:
//            print("❓ [기타]: \(firstTransaction.resourceFetchType)")
            return false
        }
    }

    func debugFullResponse(
        request: URLRequest,
        response: URLResponse?,
        data: Data?
    ) {
        print("📡 [Request]")
        print("🔹 URL:", request.url?.absoluteString ?? "-")
        print("🔹 Method:", request.httpMethod ?? "-")
        print("🔹 Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("    \(key): \(value)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("🔹 Body:\n\(bodyString)")
        } else if request.httpBody != nil {
            print("🔹 Body: <non-UTF8 data>")
        }

        print("\n📥 [Response]")
        if let httpResponse = response as? HTTPURLResponse {
            print("🔹 Status Code:", httpResponse.statusCode)
            print("🔹 Headers:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("    \(key): \(value)")
            }
        } else {
            print("🔸 응답이 HTTPURLResponse 아님")
        }

        if let data = data,
           let body = String(data: data, encoding: .utf8) {
            print("📦 [Body]\n\(body)")
        }
    }

}

class TaskDelegate: NSObject, URLSessionTaskDelegate {
    var lastMetrics: URLSessionTaskMetrics?

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        lastMetrics = metrics
    }
}

extension URLRequest {
    var curlString: String {
        var components = ["curl -X \(httpMethod ?? "GET")"]

        if let url = url {
            components.append("\"\(url.absoluteString)\"")
        }

        allHTTPHeaderFields?.forEach { components.append("-H \"\($0): \($1)\"") }

        if let url = url,
           let componentsURL = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = componentsURL.queryItems,
           !queryItems.isEmpty {
            let queryString = queryItems
                .map { "\($0.name)=\($0.value ?? "")" }
                .joined(separator: "&")
            components.append("# 🔍 query: ?\(queryString)")
        }

        if let httpBody {
            let tmpPath = NSTemporaryDirectory() + "body.data"
            let tmpURL = URL(fileURLWithPath: tmpPath)
            do {
                try httpBody.write(to: tmpURL)
                components.append("--data-binary @\(tmpPath)")
            } catch {
                components.append("# ⚠️ Failed to write body to temp file: \(error)")
            }
        }

        return components.joined(separator: " \\\n\t")
    }
}
