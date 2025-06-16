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

    init(container: DIContainer) {
        self.container = container
        self.router = container.router
    }

    var body: some View {
        NavigationStack(path: $router.currentNavigationPath) {
            TabView(selection: $router.currentTab) {
                container.makeStoreScreen()
                    .tabItem {
                        Image(systemName: TabItem.store.iconName)
                    }
                    .tag(TabItem.store)

                container.makeOrderScreen()
                    .tabItem {
                        Image(systemName: TabItem.orders.iconName)
                    }
                    .tag(TabItem.orders)

                CommunityScreen()
                    .tabItem {
                        Image(systemName: TabItem.friends.iconName)
                    }
                    .tag(TabItem.friends)

                container.makeProfileScreen()
                    .tabItem {
                        Image(systemName: TabItem.profile.iconName)
                    }
                    .tag(TabItem.profile)
            }
            .navigationDestination(for: AppRoute.self) { route in
                handleNavigation(route: route)
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
