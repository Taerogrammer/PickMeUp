//
//  StoreListStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

final class StoreListStore: ObservableObject {
    @Published private(set) var state: StoreListState
    private let effect: StoreListEffect
    private let reducer: StoreListReducer

    init(state: StoreListState, effect: StoreListEffect, reducer: StoreListReducer) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
    }

    func send(_ action: StoreListAction.Intent) {
        reducer.reduce(state: &state, action: action)
        effect.handle(action, store: self)
    }

    func send(_ result: StoreListAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}

extension StoreListStore {
    static var preview: StoreListStore {
        let mockStores = StoreMockData.samples
        var mockLoadedImages: [String: [UIImage]] = [:]

        for store in mockStores {
            mockLoadedImages[store.storeID] = Array(repeating: UIImage(systemName: "photo")!, count: 3)
        }

        let state = StoreListState(
            stores: mockStores,
            loadedImages: mockLoadedImages,
            selectedCategory: "전체"
        )
        return StoreListStore(initialState: state)
    }
}

extension StoreListStore {
    convenience init(initialState: StoreListState) {
        self.init(
            state: initialState,
            effect: StoreListEffect(),
            reducer: StoreListReducer()
        )
    }
}
