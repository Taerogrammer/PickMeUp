//
//  AppRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class AppRouter: ObservableObject {
    @Published var currentTab: TabItem = .store
    @Published var currentNavigationPath = NavigationPath()

    func navigate(to route: AppRoute) {
        navigate(to: route, in: currentTab)
    }

    func pop() {
        if !currentNavigationPath.isEmpty {
            currentNavigationPath.removeLast()
        }
    }

    func reset() {
        currentNavigationPath = NavigationPath()
    }

    func navigate(to route: AppRoute, in tab: TabItem) {
        currentTab = tab
        currentNavigationPath.append(route)
    }

    func currentPathCount() -> Int {
        return currentNavigationPath.count
    }
}
