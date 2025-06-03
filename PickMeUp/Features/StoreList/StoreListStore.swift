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

    func send(_ action: StoreListAction.Intent) {
        reducer.reduce(state: &state, action: action)
        effect.handle(action, store: self)
    }

    func send(_ result: StoreListAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
