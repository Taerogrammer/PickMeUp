//
//  TabbarScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct TabbarScreen: View {
    @ObservedObject private var router: AppRouter
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        self.router = container.router
    }

    var body: some View {
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

            container.makeChattingScreen()
                .tabItem {
                    Image(systemName: TabItem.chatting.iconName)
                }
                .tag(TabItem.chatting)

            container.makeProfileScreen()
                .tabItem {
                    Image(systemName: TabItem.profile.iconName)
                }
                .tag(TabItem.profile)
        }
        .accentColor(.deepSprout)
    }
}

#Preview {
    TabbarScreen(container: DIContainer())
}
