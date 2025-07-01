//
//  NaverGeocodingService.swift
//  PickMeUp
//
//  Created by 김태형 on 7/1/25.
//

import SwiftUI
import NMapsMap
import CoreLocation

// MARK: - 네이버 지오코딩 API 서비스 (실제 API 사용)
class NaverGeocodingService {
    static let shared = NaverGeocodingService()

    // ⚠️ 실제 API 키로 교체 필요
    private let clientId = APIEnvironment.production.naverClientID
    private let clientSecret = APIEnvironment.production.naverClientSecret

    // API URL
    private let geocodeURL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
    private let reverseGeocodeURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"

    private init() {}

    // MARK: - 주소 검색 → 좌표 변환 (GeoCoding)
    func searchAddress(query: String) async throws -> [Location] {
        guard !clientId.contains("YOUR_") else {
            // API 키가 설정되지 않은 경우 더미 데이터 반환
            return await generateMockSearchResults(for: query)
        }

        guard let url = URL(string: geocodeURL) else {
            throw NaverAPIError.invalidURL
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "coordinate", value: "127.1054221,37.3595316") // 서울 기준점
        ]

        guard let finalURL = urlComponents?.url else {
            throw NaverAPIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NaverAPIError.networkError
            }

            // 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200:
                let geocodingResponse = try JSONDecoder().decode(NaverGeocodingResponse.self, from: data)
                return parseGeocodingResponse(geocodingResponse)

            case 400:
                throw NaverAPIError.badRequest("잘못된 요청입니다. 검색어를 확인해주세요.")

            case 401:
                throw NaverAPIError.unauthorized("API 키가 유효하지 않습니다.")

            case 403:
                throw NaverAPIError.forbidden("API 호출 권한이 없습니다.")

            case 429:
                throw NaverAPIError.rateLimitExceeded("API 호출 한도를 초과했습니다.")

            case 500...599:
                throw NaverAPIError.serverError("서버 오류가 발생했습니다.")

            default:
                throw NaverAPIError.networkError
            }

        } catch let error as NaverAPIError {
            throw error
        } catch {
            throw NaverAPIError.decodingError
        }
    }

    // MARK: - 좌표 → 주소 변환 (Reverse GeoCoding)
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> ReverseGeocodingResult {
        guard !clientId.contains("YOUR_") else {
            // API 키가 설정되지 않은 경우 더미 데이터 반환
            return await generateMockReverseGeocodingResult()
        }

        guard let url = URL(string: reverseGeocodeURL) else {
            throw NaverAPIError.invalidURL
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "coords", value: "\(coordinate.longitude),\(coordinate.latitude)"),
            URLQueryItem(name: "sourcecrs", value: "epsg:4326"),
            URLQueryItem(name: "targetcrs", value: "epsg:4326"),
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "orders", value: "roadaddr,addr")
        ]

        guard let finalURL = urlComponents?.url else {
            throw NaverAPIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NaverAPIError.networkError
            }

            let reverseGeocodingResponse = try JSONDecoder().decode(NaverReverseGeocodingResponse.self, from: data)
            return parseReverseGeocodingResponse(reverseGeocodingResponse)

        } catch let error as NaverAPIError {
            throw error
        } catch {
            throw NaverAPIError.decodingError
        }
    }

    // MARK: - 응답 파싱
    private func parseGeocodingResponse(_ response: NaverGeocodingResponse) -> [Location] {
        return response.addresses.compactMap { address -> Location? in
            guard let lat = Double(address.y),
                  let lng = Double(address.x) else {
                return nil
            }

            // 건물명 추출
            let buildingName = address.addressElements?.first { element in
                element.types.contains("BUILDING_NAME")
            }?.longName

            return Location(
                id: UUID().uuidString,
                name: buildingName,
                address: address.roadAddress ?? address.jibunAddress,
                latitude: lat,
                longitude: lng,
                type: .custom
            )
        }
    }

    private func parseReverseGeocodingResponse(_ response: NaverReverseGeocodingResponse) -> ReverseGeocodingResult {
        var roadAddress: String?
        var jibunAddress: String?

        for result in response.results {
            if result.name == "roadaddr" {
                roadAddress = formatRoadAddress(result)
            } else if result.name == "addr" {
                jibunAddress = formatJibunAddress(result)
            }
        }

        return ReverseGeocodingResult(
            roadAddress: roadAddress,
            jibunAddress: jibunAddress
        )
    }

    private func formatRoadAddress(_ result: NaverReverseGeocodingResponse.Result) -> String? {
        guard let region = result.region,
              let area1 = region.area1?.name,
              let area2 = region.area2?.name,
              let area3 = region.area3?.name,
              let land = result.land?.name else {
            return nil
        }

        var components = [area1, area2, area3, land]

        // 상세 주소 추가
        if let number1 = result.land?.number1 {
            components.append(number1)
        }
        if let number2 = result.land?.number2 {
            components.append(number2)
        }

        return components.joined(separator: " ")
    }

    private func formatJibunAddress(_ result: NaverReverseGeocodingResponse.Result) -> String? {
        guard let region = result.region,
              let area1 = region.area1?.name,
              let area2 = region.area2?.name else {
            return nil
        }

        var components = [area1, area2]

        if let area3 = region.area3?.name {
            components.append(area3)
        }
        if let area4 = region.area4?.name {
            components.append(area4)
        }

        return components.joined(separator: " ")
    }

    // MARK: - 더미 데이터 (API 키 미설정시 사용)
    private func generateMockSearchResults(for query: String) async -> [Location] {
        // 시뮬레이션: 1초 지연
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let mockLocations = [
            Location(
                id: UUID().uuidString,
                name: "롯데월드타워",
                address: "서울특별시 송파구 올림픽로 300",
                latitude: 37.5125,
                longitude: 127.1025,
                type: .custom
            ),
            Location(
                id: UUID().uuidString,
                name: "강남역",
                address: "서울특별시 강남구 강남대로 390",
                latitude: 37.4979,
                longitude: 127.0276,
                type: .custom
            ),
            Location(
                id: UUID().uuidString,
                name: "선릉역",
                address: "서울특별시 강남구 테헤란로 427",
                latitude: 37.5046,
                longitude: 127.0492,
                type: .custom
            ),
            Location(
                id: UUID().uuidString,
                name: "코엑스",
                address: "서울특별시 강남구 영동대로 513",
                latitude: 37.5115,
                longitude: 127.0590,
                type: .custom
            )
        ]

        return mockLocations.filter { location in
            location.address.localizedCaseInsensitiveContains(query) ||
            (location.name?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    private func generateMockReverseGeocodingResult() async -> ReverseGeocodingResult {
        // 시뮬레이션: 0.5초 지연
        try? await Task.sleep(nanoseconds: 500_000_000)

        let mockResults = [
            ReverseGeocodingResult(
                roadAddress: "서울특별시 강남구 테헤란로 427",
                jibunAddress: "서울특별시 강남구 삼성동 143-35"
            ),
            ReverseGeocodingResult(
                roadAddress: "서울특별시 송파구 올림픽로 300",
                jibunAddress: "서울특별시 송파구 신천동 29"
            ),
            ReverseGeocodingResult(
                roadAddress: "서울특별시 강남구 강남대로 390",
                jibunAddress: "서울특별시 강남구 역삼동 837"
            )
        ]

        return mockResults.randomElement() ?? ReverseGeocodingResult(roadAddress: nil, jibunAddress: nil)
    }
}

// MARK: - API 응답 모델
struct NaverGeocodingResponse: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]

    struct Meta: Codable {
        let totalCount: Int
        let page: Int
        let count: Int
    }

    struct Address: Codable {
        let roadAddress: String?
        let jibunAddress: String
        let englishAddress: String?
        let addressElements: [AddressElement]?
        let x: String // 경도
        let y: String // 위도
        let distance: Double?

        struct AddressElement: Codable {
            let types: [String]
            let longName: String
            let shortName: String
            let code: String?
        }
    }
}

// MARK: - 네이버 GeoCoding API 서비스 (통합 버전)
class NaverReverseGeocodingService {
    static let shared = NaverReverseGeocodingService()

    private let clientId = APIEnvironment.production.naverClientID
    private let clientSecret = APIEnvironment.production.naverClientSecret
    private let baseURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"

    private init() {}

    struct GeocodingResult {
        let roadAddress: String?
        let jibunAddress: String?
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> GeocodingResult {
        // API 키가 설정되지 않은 경우 더미 데이터 사용
        guard !clientId.contains("YOUR_") else {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 딜레이

            let mockResults = [
                GeocodingResult(
                    roadAddress: "서울특별시 강남구 테헤란로 427",
                    jibunAddress: "서울특별시 강남구 삼성동 143-35"
                ),
                GeocodingResult(
                    roadAddress: "서울특별시 송파구 올림픽로 300",
                    jibunAddress: "서울특별시 송파구 신천동 29"
                ),
                GeocodingResult(
                    roadAddress: "서울특별시 강남구 강남대로 390",
                    jibunAddress: "서울특별시 강남구 역삼동 837"
                )
            ]

            return mockResults.randomElement() ?? GeocodingResult(roadAddress: nil, jibunAddress: nil)
        }

        // 실제 API 호출 코드
        guard let url = URL(string: baseURL) else {
            throw GeocodingError.invalidURL
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "coords", value: "\(coordinate.longitude),\(coordinate.latitude)"),
            URLQueryItem(name: "sourcecrs", value: "epsg:4326"),
            URLQueryItem(name: "targetcrs", value: "epsg:4326"),
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "orders", value: "roadaddr,addr")
        ]

        guard let finalURL = urlComponents?.url else {
            throw GeocodingError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw GeocodingError.networkError
            }

            let geocodingResponse = try JSONDecoder().decode(NaverReverseGeocodingAPIResponse.self, from: data)

            var roadAddress: String?
            var jibunAddress: String?

            for result in geocodingResponse.results {
                if result.name == "roadaddr" {
                    roadAddress = formatRoadAddress(result)
                } else if result.name == "addr" {
                    jibunAddress = formatJibunAddress(result)
                }
            }

            return GeocodingResult(roadAddress: roadAddress, jibunAddress: jibunAddress)

        } catch {
            throw GeocodingError.decodingError
        }
    }

    private func formatRoadAddress(_ result: NaverReverseGeocodingAPIResponse.Result) -> String? {
        guard let region = result.region,
              let area1 = region.area1?.name,
              let area2 = region.area2?.name,
              let area3 = region.area3?.name,
              let land = result.land?.name else {
            return nil
        }

        return "\(area1) \(area2) \(area3) \(land)"
    }

    private func formatJibunAddress(_ result: NaverReverseGeocodingAPIResponse.Result) -> String? {
        guard let region = result.region,
              let area1 = region.area1?.name,
              let area2 = region.area2?.name else {
            return nil
        }

        var components = [area1, area2]
        if let area3 = region.area3?.name {
            components.append(area3)
        }
        if let area4 = region.area4?.name {
            components.append(area4)
        }

        return components.joined(separator: " ")
    }
}

// MARK: - API 응답 모델
struct NaverReverseGeocodingAPIResponse: Codable {
    let status: Status
    let results: [Result]

    struct Status: Codable {
        let code: Int
        let name: String
        let message: String
    }

    struct Result: Codable {
        let name: String
        let code: Code
        let region: Region?
        let land: Land?

        struct Code: Codable {
            let id: String
            let type: String
            let mappingId: String
        }

        struct Region: Codable {
            let area0: Area?
            let area1: Area?
            let area2: Area?
            let area3: Area?
            let area4: Area?

            struct Area: Codable {
                let name: String
                let coords: Coords?

                struct Coords: Codable {
                    let center: Center

                    struct Center: Codable {
                        let crs: String
                        let x: Double
                        let y: Double
                    }
                }
            }
        }

        struct Land: Codable {
            let type: String
            let number1: String?
            let number2: String?
            let addition0: Addition?
            let addition1: Addition?
            let addition2: Addition?
            let addition3: Addition?
            let addition4: Addition?
            let name: String
            let coords: Coords?

            struct Addition: Codable {
                let type: String
                let value: String
            }

            struct Coords: Codable {
                let center: Center

                struct Center: Codable {
                    let crs: String
                    let x: Double
                    let y: Double
                }
            }
        }
    }
}

// MARK: - 결과 모델
struct ReverseGeocodingResult {
    let roadAddress: String?
    let jibunAddress: String?
}

// MARK: - 에러 정의
enum NaverAPIError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case noResults
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case rateLimitExceeded(String)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .noResults:
            return "검색 결과가 없습니다."
        case .badRequest(let message):
            return message
        case .unauthorized(let message):
            return message
        case .forbidden(let message):
            return message
        case .rateLimitExceeded(let message):
            return message
        case .serverError(let message):
            return message
        }
    }
}

enum GeocodingError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .noResults:
            return "주소를 찾을 수 없습니다."
        }
    }
}


// MARK: - 네이버 Reverse GeoCoding API 응답 모델
struct NaverReverseGeocodingResponse: Codable {
    let status: Status
    let results: [Result]

    struct Status: Codable {
        let code: Int
        let name: String
        let message: String
    }

    struct Result: Codable {
        let name: String
        let code: Code
        let region: Region?
        let land: Land?

        struct Code: Codable {
            let id: String
            let type: String
            let mappingId: String
        }

        struct Region: Codable {
            let area0: Area?
            let area1: Area?
            let area2: Area?
            let area3: Area?
            let area4: Area?

            struct Area: Codable {
                let name: String
                let coords: Coords?

                struct Coords: Codable {
                    let center: Center

                    struct Center: Codable {
                        let crs: String
                        let x: Double
                        let y: Double
                    }
                }
            }
        }

        struct Land: Codable {
            let type: String
            let number1: String?
            let number2: String?
            let addition0: Addition?
            let addition1: Addition?
            let addition2: Addition?
            let addition3: Addition?
            let addition4: Addition?
            let name: String
            let coords: Coords?

            struct Addition: Codable {
                let type: String
                let value: String
            }

            struct Coords: Codable {
                let center: Center

                struct Center: Codable {
                    let crs: String
                    let x: Double
                    let y: Double
                }
            }
        }
    }
}
