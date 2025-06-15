//
//  AppRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class AppRouter: ObservableObject {
    @Published var orderPath = NavigationPath()
    @Published var storePath = NavigationPath()
    @Published var friendsPath = NavigationPath()
    @Published var profilePath = NavigationPath()

    func navigate(to route: AppRoute, in tab: TabItem) {
        switch tab {
        case .orders:
            orderPath.append(route)
        case .store:
            storePath.append(route)
        case .friends:
            friendsPath.append(route)
        case .profile:
            profilePath.append(route)
        }
    }

    func navigate(to route: AppRoute) {
        // 라우트 타입에 따라 적절한 탭 추론
        let defaultTab: TabItem
        switch route {
        case .storeDetail:
            defaultTab = .store
        case .editProfile:
            defaultTab = .profile
        case .payment:
            defaultTab = .orders // 주문에서 결제로 가는 경우가 많음
        case .register:
            defaultTab = .profile // 회원가입은 프로필 관련
        }
        navigate(to: route, in: defaultTab)
    }

    // 현재 탭의 경로 초기화
    func reset(tab: TabItem) {
        switch tab {
        case .orders:
            orderPath = NavigationPath()
        case .store:
            storePath = NavigationPath()
        case .friends:
            friendsPath = NavigationPath()
        case .profile:
            profilePath = NavigationPath()
        }
    }

    // 기존 호환성을 위한 reset (모든 탭 초기화)
    func reset() {
        orderPath = NavigationPath()
        storePath = NavigationPath()
        friendsPath = NavigationPath()
        profilePath = NavigationPath()
    }

    // 현재 탭에서 뒤로가기
    func pop(from tab: TabItem) {
        switch tab {
        case .orders:
            if !orderPath.isEmpty { orderPath.removeLast() }
        case .store:
            if !storePath.isEmpty { storePath.removeLast() }
        case .friends:
            if !friendsPath.isEmpty { friendsPath.removeLast() }
        case .profile:
            if !profilePath.isEmpty { profilePath.removeLast() }
        }
    }

    // 기존 호환성을 위한 pop (현재 컨텍스트에서 추론)
    func pop() {
        // 가장 최근에 변경된 path에서 pop
        // 실제로는 각 Store에서 적절한 탭을 명시하는 것이 좋음
        if !orderPath.isEmpty {
            orderPath.removeLast()
        } else if !storePath.isEmpty {
            storePath.removeLast()
        } else if !profilePath.isEmpty {
            profilePath.removeLast()
        } else if !friendsPath.isEmpty {
            friendsPath.removeLast()
        }
    }
}
