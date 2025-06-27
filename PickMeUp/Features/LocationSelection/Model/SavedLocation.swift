//
//  SavedLocation.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct Location: Identifiable, Equatable {
    let id: String
    let name: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let type: LocationType

    // 표시용 이름
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        } else {
            return shortAddress
        }
    }

    // 축약된 주소 생성
    var shortAddress: String {
        let components = address.components(separatedBy: " ")

        if components.count >= 3 {
            // 시/도 제거하고 구부터 표시
            return components.dropFirst().joined(separator: " ")
        } else {
            return address
        }
    }

    // 아이콘
    var icon: String {
        return type.icon
    }

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}

struct LocationDummyData {
    static let defaultLocations: [Location] = [
        Location(
            id: "default",
            name: nil,
            address: "서울특별시 도봉구 방학로 310",
            latitude: 37.6658609,
            longitude: 127.0317674,
            type: .system
        ),
        Location(
            id: "home-001",
            name: "우리집",
            address: "인천광역시 부평구 마장로264번길 33",
            latitude: 37.5085,
            longitude: 126.7253,
            type: .home
        ),
        Location(
            id: "work-001",
            name: "회사",
            address: "서울특별시 강남구 테헤란로 123",
            latitude: 37.497175,
            longitude: 127.027621,
            type: .work
        ),
        Location(
            id: "custom-001",
            name: nil, // 이름 없는 위치 (shortAddress 테스트용)
            address: "서울특별시 마포구 홍익로 94",
            latitude: 37.5503,
            longitude: 126.9230,
            type: .custom
        ),
        Location(
            id: "custom-002",
            name: "자주 가는 카페",
            address: "서울특별시 종로구 인사동길 12",
            latitude: 37.5712,
            longitude: 126.9882,
            type: .custom
        )
    ]

    // 검색 결과용 더미 데이터
    static let searchResultLocations: [Location] = [
        Location(
            id: "search-001",
            name: nil,
            address: "서울특별시 송파구 올림픽로 300",
            latitude: 37.5145,
            longitude: 127.1059,
            type: .custom
        ),
        Location(
            id: "search-002",
            name: nil,
            address: "서울특별시 중구 명동길 26",
            latitude: 37.5636,
            longitude: 126.9826,
            type: .custom
        ),
        Location(
            id: "search-003",
            name: nil,
            address: "서울특별시 용산구 이태원로 200",
            latitude: 37.5344,
            longitude: 126.9947,
            type: .custom
        )
    ]
}
