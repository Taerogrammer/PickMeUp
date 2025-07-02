//
//  NaverGeocodingService.swift
//  PickMeUp
//
//  Created by 김태형 on 7/1/25.
//

import SwiftUI
import NMapsMap
import CoreLocation

// MARK: - 네이버 지오코딩 서비스
final class NaverGeocodingService {
    static let shared = NaverGeocodingService()

    private let clientId = APIEnvironment.production.naverClientID
    private let clientSecret = APIEnvironment.production.naverClientSecret
    private let baseURL = "https://maps.apigw.ntruss.com/map-geocode/v2"

    private init() {}

    // MARK: - 주소 검색 (Geocoding)
    func searchAddress(query: String) async throws -> [Location] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NaverGeocodingError.invalidQuery
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/geocode?query=\(encodedQuery)"

        guard let url = URL(string: urlString) else {
            throw NaverGeocodingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 디버깅을 위한 로그
        #if DEBUG
        print("🌐 Geocoding API Request:")
        print("URL: \(request.url?.absoluteString ?? "")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        #endif

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            #if DEBUG
            print("📡 API Response Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response Data: \(responseString)")
            }
            #endif

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NaverGeocodingError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw NaverGeocodingError.unauthorized
            } else if httpResponse.statusCode == 429 {
                throw NaverGeocodingError.rateLimitExceeded
            } else if httpResponse.statusCode != 200 {
                throw NaverGeocodingError.serverError(httpResponse.statusCode)
            }

            let geocodingResponse = try JSONDecoder().decode(NaverGeocodingResponse.self, from: data)

            if geocodingResponse.status != "OK" {
                throw NaverGeocodingError.apiError(geocodingResponse.errorMessage ?? "Unknown error")
            }

            return geocodingResponse.addresses.compactMap { address in
                guard let latitude = Double(address.y),
                      let longitude = Double(address.x) else {
                    return nil
                }

                // 도로명 주소를 우선으로 하되, 없으면 지번 주소 사용
                let displayAddress = address.roadAddress ?? address.jibunAddress ?? ""

                // 건물명이나 주요 지명 추출
                let buildingName = extractBuildingName(from: address.addressElements)

                return Location(
                    id: UUID().uuidString,
                    name: buildingName,
                    address: displayAddress,
                    latitude: latitude,
                    longitude: longitude,
                    type: .custom
                )
            }

        } catch let error as NaverGeocodingError {
            throw error
        } catch {
            throw NaverGeocodingError.networkError(error)
        }
    }

    // MARK: - 역지오코딩 (좌표 -> 주소)
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> Location? {
        let urlString = "https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=\(longitude),\(latitude)&output=json"

        guard let url = URL(string: urlString) else {
            throw NaverGeocodingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NaverGeocodingError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw NaverGeocodingError.unauthorized
            } else if httpResponse.statusCode == 429 {
                throw NaverGeocodingError.rateLimitExceeded
            } else if httpResponse.statusCode != 200 {
                throw NaverGeocodingError.serverError(httpResponse.statusCode)
            }

            let reverseResponse = try JSONDecoder().decode(NaverReverseGeocodingResponse.self, from: data)

            if reverseResponse.status.code != 0 {
                throw NaverGeocodingError.apiError(reverseResponse.status.message)
            }

            guard let result = reverseResponse.results.first,
                  let region = result.region,
                  let land = result.land else {
                return nil
            }

            // 주소 구성
            let address = buildAddress(from: region, land: land)

            return Location(
                id: UUID().uuidString,
                name: nil,
                address: address,
                latitude: latitude,
                longitude: longitude,
                type: .custom
            )

        } catch let error as NaverGeocodingError {
            throw error
        } catch {
            throw NaverGeocodingError.networkError(error)
        }
    }

    // MARK: - Private Methods
    private func extractBuildingName(from elements: [NaverGeocodingResponse.Address.AddressElement]) -> String? {
        // 건물명이나 주요 지명을 찾아서 반환
        for element in elements {
            if element.types.contains("BUILDING_NAME") ||
               element.types.contains("LAND_NUMBER") ||
               element.types.contains("POSTAL_CODE") {
                continue
            }

            if element.types.contains("BUILDING") ||
               element.types.contains("ESTABLISHMENT") {
                return element.longName
            }
        }

        return nil
    }

    private func buildAddress(from region: NaverReverseGeocodingResponse.Result.Region,
                            land: NaverReverseGeocodingResponse.Result.Land) -> String {
        var addressComponents: [String] = []

        // 시도
        if let area1 = region.area1?.name {
            addressComponents.append(area1)
        }

        // 시군구
        if let area2 = region.area2?.name {
            addressComponents.append(area2)
        }

        // 읍면동
        if let area3 = region.area3?.name {
            addressComponents.append(area3)
        }

        // 리
        if let area4 = region.area4?.name {
            addressComponents.append(area4)
        }

        // 번지
        if let number1 = land.number1, !number1.isEmpty {
            if let number2 = land.number2, !number2.isEmpty {
                addressComponents.append("\(number1)-\(number2)")
            } else {
                addressComponents.append(number1)
            }
        }

        return addressComponents.joined(separator: " ")
    }
}
