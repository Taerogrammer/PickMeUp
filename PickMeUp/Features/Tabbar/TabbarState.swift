//
//  TabbarState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import Foundation

struct TabbarState {
    var selectedTab: TabItem = .store
}

enum TabItem: Hashable, CaseIterable {
    case store, orders, friends, profile

    var iconName: String {
        switch self {
        case .store: return "house.fill"
        case .orders: return "doc.text"
        case .friends: return "person.2"
        case .profile: return "person.crop.circle"
        }
    }
}
