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
