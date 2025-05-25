//
//  ContentView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var router: AppRouter
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        self.router = container.router
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            container.makeLandingView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .register:
                        container.makeRegisterView()
                    case .home:
                        container.makeTabbarView()
                    }
                }
        }
    }
}

#Preview {
    let container = DIContainer()
    return AppRootView(container: container)
}
