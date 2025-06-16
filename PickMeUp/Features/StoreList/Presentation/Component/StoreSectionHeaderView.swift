//
//  StoreSectionHeaderView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI

struct StoreSectionHeaderView: View {
    @ObservedObject var store: StoreListStore
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)

                Spacer()

                if store.state.showSortButton {
                    Button {
                        store.send(.sortByDistance)
                    } label: {
                        HStack(spacing: 4) {
                            Text("거리순")
                                .font(.pretendardCaption1)
                                .foregroundColor(.deepSprout)
                            Image(systemName: "chart.bar.yaxis")
                                .font(.system(size: 16))
                                .foregroundColor(.deepSprout)
                        }
                    }
                }
            }

            if store.state.showFilter {
                HStack(spacing: 12) {
                    Button {
                        store.send(.togglePickchelin)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.deepSprout)
                            Text("픽슐랭")
                                .font(.pretendardCaption2)
                                .foregroundColor(.deepSprout)
                        }
                        .opacity(store.state.isPickchelinOn ? 1.0 : 0.3)
                    }

                    Button {
                        store.send(.toggleMyPick)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blackSprout)
                            Text("My Pick")
                                .font(.pretendardCaption2)
                                .foregroundColor(.blackSprout)
                        }
                        .opacity(store.state.isMyPickOn ? 1.0 : 0.3)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}
