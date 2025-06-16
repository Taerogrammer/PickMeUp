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
        case .storeItemOnAppear: break
        case .tapStore: break
        case .loadNextPage:
            if !state.isLoadingMore && !state.hasReachedEnd && state.nextCursor != nil {
                state.isLoadingMore = true
            }
        }
    }

    func reduce(state: inout StoreListState, result: StoreListAction.Result) {
        switch result {
        case .fetchFailed(let message):
            state.errorMessage = message

        case .loadImageSuccess(let storeID, let images):
            state.loadedImages[storeID] = images.compactMap { $0 }
            state.imageLoadErrors.removeValue(forKey: storeID)

        case .loadImageFailed(let storeID, let errorMessage):
            state.imageLoadErrors[storeID] = errorMessage

        case .fetchStoresWithCursor(let stores, let nextCursor):
            state.stores = stores
            state.nextCursor = nextCursor
            state.hasReachedEnd = (nextCursor == nil || nextCursor == "0")
            state.errorMessage = nil

        case .loadMoreSuccess(let newStores, let nextCursor):
            state.stores.append(contentsOf: newStores)
            state.nextCursor = nextCursor
            state.hasReachedEnd = (nextCursor == nil || nextCursor == "0")
            state.isLoadingMore = false
            state.errorMessage = nil

        case .loadMoreFailed(let message):
            state.errorMessage = message
            state.isLoadingMore = false
        }
    }
}
