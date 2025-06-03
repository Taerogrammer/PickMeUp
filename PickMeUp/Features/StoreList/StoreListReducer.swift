//
//  StoreListReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreListReducer {
    func reduce(state: inout StoreListState, action: StoreListAction.Intent) {
        switch action {
        case .onAppear:
            break // Effect triggered
        case .selectCategory(let category):
            state.selectedCategory = category
        case .togglePickchelin:
            state.isPickchelinOn.toggle()
        case .toggleMyPick:
            state.isMyPickOn.toggle()
        case .sortByDistance:
            state.stores.sort { $0.distance < $1.distance }
        }
    }

    func reduce(state: inout StoreListState, result: StoreListAction.Result) {
        switch result {
        case .fetchStores(let stores):
            state.stores = stores
            state.errorMessage = nil
        case .fetchFailed(let message):
            state.errorMessage = message
        }
    }
}
