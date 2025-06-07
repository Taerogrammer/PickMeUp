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
        case .onAppear: break
        case .selectCategory(let category):
            state.selectedCategory = category
        case .togglePickchelin:
            state.isPickchelinOn.toggle()
        case .toggleMyPick:
            state.isMyPickOn.toggle()
        case .sortByDistance:
            state.stores.sort { $0.distance < $1.distance }
        case .storeItemOnAppear(let storeID, _):
            if state.loadedImages[storeID] == nil {
                // 여기선 상태만 봄, loadImage는 Effect에서 실행
            }
        case .tapStore: break
        case .loadImage: break
        }
    }

    func reduce(state: inout StoreListState, result: StoreListAction.Result) {
        switch result {
        case .fetchStores(let stores):
            state.stores = stores
            state.errorMessage = nil
        case .fetchFailed(let message):
            state.errorMessage = message
        case .loadImageSuccess(let storeID, let images):
            state.loadedImages[storeID] = images.compactMap { $0 }
        case .loadImageFailed(_, let errorMessage):
            state.errorMessage = errorMessage
        case .fetchStoresWithCursor(let stores, let nextCursor):
            state.stores = stores
            state.nextCursor = nextCursor  // Reducer에서만 State 변경
            state.errorMessage = nil
        }
    }
}
