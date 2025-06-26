//
//  SavedLocation.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

// MARK: - Domain Models
struct SavedLocation: Identifiable, Equatable {
    let id: String
    let name: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let type: LocationType
    let isDefault: Bool
    let createdAt: Date

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

    static func == (lhs: SavedLocation, rhs: SavedLocation) -> Bool {
        return lhs.id == rhs.id
    }
}
