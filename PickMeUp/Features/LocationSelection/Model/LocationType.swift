//
//  LocationType.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

enum LocationType: String, CaseIterable {
    case system = "system"
    case home = "home"
    case work = "work"
    case custom = "custom"

    var isDeletable: Bool {
        return self != .system
    }

    var displayName: String {
        switch self {
        case .system: return "기본 위치"
        case .home: return "집"
        case .work: return "회사"
        case .custom: return "기타"
        }
    }

    var icon: String {
        switch self {
        case .system: return "building.2"
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .custom: return "mappin.circle.fill"
        }
    }
}

// MARK: - Search Result Model
struct LocationSearchResult {
    let roadAddress: String
    let jibunAddress: String
    let latitude: Double
    let longitude: Double

    var displayAddress: String {
        return roadAddress.isEmpty ? jibunAddress : roadAddress
    }
}

// MARK: - Dummy Data
struct LocationDummyData {
    static let defaultLocations: [SavedLocation] = [
        SavedLocation(
            id: "default",
            name: nil,
            address: "서울특별시 도봉구 방학로 310",
            latitude: 37.6658609,
            longitude: 127.0317674,
            type: .system,
            isDefault: true,
            createdAt: Date().addingTimeInterval(-86400 * 30) // 30일 전
        ),
        SavedLocation(
            id: "home-001",
            name: "우리집",
            address: "인천광역시 부평구 마장로264번길 33",
            latitude: 37.5085,
            longitude: 126.7253,
            type: .home,
            isDefault: false,
            createdAt: Date().addingTimeInterval(-86400 * 7) // 7일 전
        ),
        SavedLocation(
            id: "work-001",
            name: "회사",
            address: "서울특별시 강남구 테헤란로 123",
            latitude: 37.497175,
            longitude: 127.027621,
            type: .work,
            isDefault: false,
            createdAt: Date().addingTimeInterval(-86400 * 3) // 3일 전
        ),
        SavedLocation(
            id: "custom-001",
            name: nil, // 이름 없는 위치 (shortAddress 테스트용)
            address: "서울특별시 마포구 홍익로 94",
            latitude: 37.5503,
            longitude: 126.9230,
            type: .custom,
            isDefault: false,
            createdAt: Date().addingTimeInterval(-86400) // 1일 전
        ),
        SavedLocation(
            id: "custom-002",
            name: "자주 가는 카페",
            address: "서울특별시 종로구 인사동길 12",
            latitude: 37.5712,
            longitude: 126.9882,
            type: .custom,
            isDefault: false,
            createdAt: Date() // 오늘
        )
    ]

    static let searchResults: [LocationSearchResult] = [
        LocationSearchResult(
            roadAddress: "서울특별시 송파구 올림픽로 300",
            jibunAddress: "서울특별시 송파구 신천동 7-47",
            latitude: 37.5145,
            longitude: 127.1059
        ),
        LocationSearchResult(
            roadAddress: "서울특별시 중구 명동길 26",
            jibunAddress: "서울특별시 중구 명동2가 54-1",
            latitude: 37.5636,
            longitude: 126.9826
        ),
        LocationSearchResult(
            roadAddress: "서울특별시 용산구 이태원로 200",
            jibunAddress: "서울특별시 용산구 이태원동 119-25",
            latitude: 37.5344,
            longitude: 126.9947
        )
    ]
}
