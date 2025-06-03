//
//  StoreListStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

final class StoreListStore: ObservableObject {
    @Published private(set) var state: StoreListState
    private let effect = StoreListEffect()
    private let reducer = StoreListReducer()

    init(initialState: StoreListState = StoreListState()) {
        self.state = initialState
    }

    func send(_ intent: StoreListIntent) {
        reducer.reduce(state: &state, intent: intent)
        effect.handle(intent, store: self)
    }
}
