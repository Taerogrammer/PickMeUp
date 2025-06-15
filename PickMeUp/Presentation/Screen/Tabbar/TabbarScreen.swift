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
            NavigationStack(path: $router.storePath) {
                storeScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: "storefront")
                Text("매장")
            }

            // 주문 탭 - 독립적인 NavigationPath 사용
            NavigationStack(path: $router.orderPath) {
                orderScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: "list.bullet.clipboard")
                Text("주문")
            }

            // 친구 탭 - 독립적인 NavigationPath 사용
            NavigationStack(path: $router.friendsPath) {
                CommunityScreen()       // TODO: - 수정
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: "person.2")
                Text("친구")
            }

            // 프로필 탭 - 독립적인 NavigationPath 사용
            NavigationStack(path: $router.profilePath) {
                profileScreen
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
            }
            .tabItem {
                Image(systemName: "person.circle")
                Text("프로필")
            }
        }
    }

    // MARK: - Navigation 처리
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
