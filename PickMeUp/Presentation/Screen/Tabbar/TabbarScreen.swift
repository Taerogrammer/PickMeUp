//
//  TabbarScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct TabbarScreen: View {
    private let container: DIContainer
    @ObservedObject private var router: AppRouter

    private let storeScreen: AnyView
    private let orderScreen: AnyView
    private let profileScreen: AnyView

    init(container: DIContainer) {
        self.container = container
        self.router = container.router

        self.storeScreen = container.makeStoreScreen()
        self.orderScreen = container.makeOrderScreen()
        self.profileScreen = container.makeProfileScreen()
    }

    var body: some View {
        TabView {
            NavigationStack(path: $router.storeNavigationPath) {
                storeScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: TabItem.store.iconName)
            }

            NavigationStack(path: $router.orderNavigationPath) {
                orderScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: TabItem.orders.iconName)
            }

            NavigationStack(path: $router.friendsNavigationPath) {
                CommunityScreen()       // TODO: - 수정
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: TabItem.friends.iconName)
            }

            NavigationStack(path: $router.profileNavigationPath) {
                profileScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: TabItem.profile.iconName)
            }
        }
        .accentColor(.deepSprout)
    }

    @ViewBuilder
    private func handleNavigation(route: AppRoute) -> some View {
        switch route {
        case .register:
            container.makeRegisterScreen()
        case .editProfile(let user):
            container.makeProfileEditView(user: user)
        case .storeDetail(let storeID):
            container.makeStoreDetailScreen(storeID: storeID)
        case .payment(let paymentInfo):
            container.makePaymentView(paymentInfo: paymentInfo)
        }
    }
}

#Preview {
    TabbarScreen(container: DIContainer())
}
