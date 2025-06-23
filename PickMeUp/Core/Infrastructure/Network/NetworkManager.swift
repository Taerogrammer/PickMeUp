//
//  RequestManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation
import Network

final class NetworkManager {
    static let shared = NetworkManager()

    /// 네트워크 관리를 위한 속성
    private let networkMonitor = NWPathMonitor()
    private var currentSession: URLSession!
    private var networkMetrics = NetworkMetrics()
    private let metricsQueue = DispatchQueue(label: "NetworkMetrics", qos: .utility)

    // 네트워크 성능 지표
    private struct NetworkMetrics {
        var connectionCount = 6 // 기본 httpMaximumConnectionsPerHost: 6
        var totalRequests = 0
        var successfulRequests = 0
        var cacheHits = 0
        var networkLoads = 0
        var responseTimes: [TimeInterval] = []
        var errorCount = 0

        // 계산된 지표
        var successRate: Double {
            guard totalRequests > 0 else { return 1.0 }
            return Double(successfulRequests) / Double(totalRequests)
        }

        var cacheHitRate: Double {
            let totalDataRequests = cacheHits + networkLoads
            guard totalDataRequests > 0 else { return 0.0 }
            return Double(cacheHits) / Double(totalDataRequests)
        }

        var averageResponseTime: TimeInterval {
            guard !responseTimes.isEmpty else { return 1.0 }
            return responseTimes.reduce(0, +) / Double(responseTimes.count)
        }

        mutating func addResponseTime(_ time: TimeInterval) {
            responseTimes.append(time)

            // 최근 20개만 유지
            if responseTimes.count > 20 {
                responseTimes.removeFirst()
            }
        }
    }

    private init() {
        setupInitialSession()
        startNetworkMonitoring()
    }

    private func setupInitialSession() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = networkMetrics.connectionCount
        currentSession = URLSession(configuration: config)
    }

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkPathChange(path)
        }

        let queue = DispatchQueue(label: "NetworkPathMonitor")
        networkMonitor.start(queue: queue)
    }

    private func handleNetworkPathChange(_ path: NWPath) {
        metricsQueue.async { [weak self] in
            self?.optimizeConnectionsForNetworkType(path)
        }
    }

    private func optimizeConnectionsForNetworkType(_ path: NWPath) {
        var baseConnections: Int

        if path.usesInterfaceType(.wifi) {
            baseConnections = 8
        } else if path.usesInterfaceType(.cellular) {
            baseConnections = 4
        } else {
            baseConnections = 6
        }

        // 성능 지표를 바탕으로 추가 조정
        baseConnections = adjustConnectionsBasedOnMetrics(baseConnections)

        updateSessionIfNeeded(newConnectionCount: baseConnections)
    }

    private func adjustConnectionsBasedOnMetrics(_ baseConnections: Int) -> Int {
        var adjustedConnections = baseConnections

        // 성공률과 응답시간을 고려한 조정
        if networkMetrics.successRate > 0.95 && networkMetrics.averageResponseTime < 2.0 {
            adjustedConnections += 2
        } else if networkMetrics.successRate < 0.8 || networkMetrics.averageResponseTime > 5.0 {
            adjustedConnections -= 2
        }

        // 캐시 히트율을 고려한 조정
        if networkMetrics.cacheHitRate > 0.7 {
            adjustedConnections -= 1
        } else if networkMetrics.cacheHitRate < 0.3 && networkMetrics.networkLoads > 10 {
            adjustedConnections += 1
        }

        // 에러율을 고려한 조정
        let errorRate = Double(networkMetrics.errorCount) / Double(max(networkMetrics.totalRequests, 1))
        if errorRate > 0.2 {
            adjustedConnections -= 1
        }

        // 최소 2개, 최대 12개로 제한
        return max(2, min(adjustedConnections, 12))
    }

    private func updateSessionIfNeeded(newConnectionCount: Int) {
        guard newConnectionCount != networkMetrics.connectionCount else { return }

        networkMetrics.connectionCount = newConnectionCount

        DispatchQueue.main.async { [weak self] in
            let config = URLSessionConfiguration.default
            config.httpMaximumConnectionsPerHost = newConnectionCount

            // 기존 캐시 정책 유지 (304 대신 resourceFetchType 활용)
            config.requestCachePolicy = .useProtocolCachePolicy
            config.urlCache = URLCache.shared

            self?.currentSession = URLSession(configuration: config)
            print("🔧 연결 수 조정: \(newConnectionCount)개 (캐시율: \(String(format: "%.1f", self?.networkMetrics.cacheHitRate ?? 0 * 100))%, 성공률: \(String(format: "%.1f", self?.networkMetrics.successRate ?? 0 * 100))%)")
        }
    }

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
        let session = currentSession ?? URLSession.shared

        let startTime = CFAbsoluteTimeGetCurrent()
        let (data, response) = try await session.data(for: urlRequest)
        let endTime = CFAbsoluteTimeGetCurrent()
        let responseTime = endTime - startTime

        let isFromCache = checkCacheStatus(metrics: delegate.lastMetrics)

        // 메트릭 업데이트
        updateNetworkMetrics(
            responseTime: responseTime,
            isFromCache: isFromCache,
            response: response
        )

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

    private func updateNetworkMetrics(
        responseTime: TimeInterval,
        isFromCache: Bool,
        response: URLResponse?
    ) {
        metricsQueue.async { [weak self] in
            guard let self = self else { return }

            self.networkMetrics.totalRequests += 1
            self.networkMetrics.addResponseTime(responseTime)

            if isFromCache {
                self.networkMetrics.cacheHits += 1
            } else {
                self.networkMetrics.networkLoads += 1
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    self.networkMetrics.successfulRequests += 1
                } else if (400...599).contains(httpResponse.statusCode) {
                    self.networkMetrics.errorCount += 1
                }
            }

            // 100번의 요청마다 연결 수 최적화 재평가
            if self.networkMetrics.totalRequests % 100 == 0 {
                let path = self.networkMonitor.currentPath
                self.optimizeConnectionsForNetworkType(path)
            }
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

    // 현재 네트워크 상태를 확인할 수 있는 디버그 메서드
    func printCurrentNetworkStatus() {
        metricsQueue.async { [weak self] in
            guard let self = self else { return }

            print("📊 [네트워크 상태]")
            print("🔗 현재 연결 수: \(self.networkMetrics.connectionCount)")
            print("📈 총 요청 수: \(self.networkMetrics.totalRequests)")
            print("✅ 성공률: \(String(format: "%.1f", self.networkMetrics.successRate * 100))%")
            print("💾 캐시 히트율: \(String(format: "%.1f", self.networkMetrics.cacheHitRate * 100))%")
            print("⏱️ 평균 응답시간: \(String(format: "%.2f", self.networkMetrics.averageResponseTime))초")
            print("❌ 에러 수: \(self.networkMetrics.errorCount)")

            let networkType = self.networkMonitor.currentPath.usesInterfaceType(.wifi) ? "WiFi" :
                             self.networkMonitor.currentPath.usesInterfaceType(.cellular) ? "Cellular" : "기타"
            print("🌐 네트워크 타입: \(networkType)")
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
