//
//  TabbarView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct TabbarView: View {
    @StateObject private var store: TabbarStore
    private let onTabSelected: (TabItem) -> AnyView

    init(store: TabbarStore, onTabSelected: @escaping (TabItem) -> AnyView) {
        _store = StateObject(wrappedValue: store)
        self.onTabSelected = onTabSelected
    }

    public var body: some View {
        VStack(spacing: 0) {
            onTabSelected(store.state.selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray0)

            HStack {
                ForEach(TabItem.allCases, id: \.self) { item in
                    tabBarButton(for: item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.gray0)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
        }
        .background(Color.white.ignoresSafeArea())
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
            .padding(.vertical, 12)
        }
        .foregroundColor(store.state.selectedTab == item ? .orange : .gray)
    }
}

#Preview {
    let container = DIContainer()
    let store = TabbarStore(router: container.router)
    return TabbarView(store: store) { tab in
        switch tab {
        case .store:
            return AnyView(StoreScreen())
        case .orders:
            return AnyView(OrderView())
        case .friends:
            return AnyView(CommunityView())
        case .profile:
            return container.makeProfileScreen()
        }
    }
}
