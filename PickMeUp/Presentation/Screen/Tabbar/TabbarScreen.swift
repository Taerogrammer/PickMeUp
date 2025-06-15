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
            case .store:
                container.makeStoreScreen()
            case .orders:
                container.makeOrderScreen()
            case .friends:
                AnyView(CommunityScreen())
            case .profile:
                container.makeProfileScreen()
            }
        }
    }
}

#Preview {
    TabbarScreen(container: DIContainer())
}
