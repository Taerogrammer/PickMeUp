//
//  TabbarScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct TabbarScreen: View {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        let store = TabbarStore(router: container.router)
        TabbarView(store: store) { tab in
            switch tab {
            case .home:
                AnyView(HomeView())
            case .orders:
                AnyView(OrderView())
            case .friends:
                AnyView(CommunityView())
            case .profile:
                container.makeProfileView()
            }
        }
    }
}

#Preview {
    TabbarScreen(container: DIContainer())
}
