//
//  AppRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class AppRouter: ObservableObject {
    @Published var currentTab: TabItem = .store
    @Published var storeNavigationPath = NavigationPath()
    @Published var orderNavigationPath = NavigationPath()
    @Published var friendsNavigationPath = NavigationPath()
    @Published var profileNavigationPath = NavigationPath()

    func navigate(to route: AppRoute) { navigate(to: route, in: currentTab) }

    func pop() { pop(from: currentTab) }

    func reset() { reset(tab: currentTab) }

    func navigate(to route: AppRoute, in tab: TabItem) {
        switch tab {
        case .store:
            storeNavigationPath.append(route)
        case .orders:
            orderNavigationPath.append(route)
        case .friends:
            friendsNavigationPath.append(route)
        case .profile:
            profileNavigationPath.append(route)
        }
    }

    func pop(from tab: TabItem) {
        switch tab {
        case .store:
            if !storeNavigationPath.isEmpty { storeNavigationPath.removeLast() }
        case .orders:
            if !orderNavigationPath.isEmpty { orderNavigationPath.removeLast() }
        case .friends:
            if !friendsNavigationPath.isEmpty { friendsNavigationPath.removeLast() }
        case .profile:
            if !profileNavigationPath.isEmpty { profileNavigationPath.removeLast() }
        }
    }

    func reset(tab: TabItem) {
        switch tab {
        case .store:
            storeNavigationPath = NavigationPath()
        case .orders:
            orderNavigationPath = NavigationPath()
        case .friends:
            friendsNavigationPath = NavigationPath()
        case .profile:
            profileNavigationPath = NavigationPath()
        }
    }

    func resetAll() {
        storeNavigationPath = NavigationPath()
        orderNavigationPath = NavigationPath()
        friendsNavigationPath = NavigationPath()
        profileNavigationPath = NavigationPath()
    }
}
