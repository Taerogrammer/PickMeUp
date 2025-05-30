//
//  TabbarView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct TabbarView: View {
    @StateObject private var store: TabbarStore
    private let container: DIContainer

    init(store: TabbarStore, container: DIContainer) {
        _store = StateObject(wrappedValue: store)
        self.container = container
    }

    var body: some View {
        VStack(spacing: 0) {
            tabContentView(for: store.state.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))

            HStack {
                ForEach(TabItem.allCases, id: \.self) { item in
                    tabBarButton(for: item)
                }
            }
            .padding(.horizontal, 16)
            .background(
                Color(.systemGray6)
                    .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    @ViewBuilder
    private func tabContentView(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .orders:
            OrderView()
        case .friends:
            CommunityView()
        case .profile:
            container.makeProfileView()
        }
    }

    private func tabBarButton(for item: TabItem) -> some View {
        Button {
            store.send(.selectTab(item))
        } label: {
            VStack(spacing: 6) {
                Image(systemName: item.iconName)
                    .font(.system(size: 32))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .foregroundColor(store.state.selectedTab == item ? .orange : .gray)
    }
}

#Preview {
    let dummyRouter = AppRouter()
    let store = TabbarStore(router: dummyRouter)
    TabbarView(store: store, container: DIContainer())
}
