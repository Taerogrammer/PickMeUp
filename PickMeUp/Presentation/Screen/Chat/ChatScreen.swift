//
//  ChattingScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatScreen: View {
    @ObservedObject private var store: ChatListStore

    init(store: ChatListStore) {
        self.store = store
    }

    var body: some View {
        ChatListView(store: store)
    }
}

//#Preview {
//    ChatScreen()
//}
