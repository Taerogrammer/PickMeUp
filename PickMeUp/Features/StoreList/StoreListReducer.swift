//
//  StoreListReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreListReducer {
    func reduce(state: inout StoreListState, intent: StoreListIntent) {
        switch intent {
        case .fetchStores(let stores):
            state.stores = stores
            state.errorMessage = nil

        case .fetchFailed(let message):
            state.errorMessage = message

        case .togglePickchelin:
            state.isPickchelinOn.toggle()

        case .toggleMyPick:
            state.isMyPickOn.toggle()

        case .selectCategory(let category):
            state.selectedCategory = category

        case .onAppear:
            break // Effect handles
        }
    }
}
