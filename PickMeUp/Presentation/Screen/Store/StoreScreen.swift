//
//  StoreScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import SwiftUI

struct StoreScreen: View {
    @ObservedObject private var store: StoreListStore

    init(store: StoreListStore) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            StoreSearchHeaderView()
            StoreListView(store: store)
        }
        .background(Color.gray30)
    }
}

//#Preview {
//    StoreScreen(store: .preview)
//}
