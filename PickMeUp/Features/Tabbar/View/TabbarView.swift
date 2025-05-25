//
//  TabbarView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/25/25.
//

import SwiftUI

struct TabbarView: View {
    @StateObject private var viewModel: TabbarViewModel
    private let container: DIContainer

    init(viewModel: TabbarViewModel, container: DIContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }

    var body: some View {
        VStack(spacing: 0) {
            // 선택된 탭에 따라 메인 화면 변경
            Group {
                switch viewModel.state.selectedTab {
                case .home:
                    HomeView()
                case .orders:
                    OrderView()
                case .friends:
                    CommunityView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))

            // 하단 탭바
            HStack {
                ForEach(TabItem.allCases, id: \.self) { item in
                    VStack(spacing: 4) {
                        Image(systemName: item.iconName)
                            .font(.body)
                        Text(item.title)
                            .font(.caption2)
                    }
                    .foregroundColor(viewModel.state.selectedTab == item ? .orange : .gray)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.handle(.selectTab(item))
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
        }
    }
}

#Preview {
    let dummyRouter = AppRouter()
    let viewModel = TabbarViewModel(initialState: TabbarState(selectedTab: .home), router: dummyRouter)
    TabbarView(viewModel: viewModel, container: DIContainer())
}
