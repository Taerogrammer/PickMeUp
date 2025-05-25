//
//  TabbarState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import Foundation

struct TabbarState {
    var selectedTab: TabItem = .home
}

enum TabItem: Hashable, CaseIterable {
    case home, orders, friends, profile

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .orders: return "doc.text"
        case .friends: return "person.2"
        case .profile: return "person.crop.circle"
        }
    }

    var title: String {
        switch self {
        case .home: return "홈"
        case .orders: return "주문내역"
        case .friends: return "친구"
        case .profile: return "내정보"
        }
    }
}
