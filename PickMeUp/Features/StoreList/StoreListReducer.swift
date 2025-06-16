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
        case .loadNextPage:
            if !state.isLoadingMore && !state.hasReachedEnd && state.nextCursor != nil {
                state.isLoadingMore = true
                print("📝 다음 페이지 로딩 시작")
            }
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

        // 🔑 첫 페이지 로드 (nextCursor와 함께)
        case .fetchStoresWithCursor(let stores, let nextCursor):
            state.stores = stores
            state.nextCursor = nextCursor
            state.hasReachedEnd = (nextCursor == nil || nextCursor == "0")
            state.errorMessage = nil
            print("📝 Reducer에서 nextCursor 저장: \(nextCursor ?? "nil")")
            print("📝 hasReachedEnd: \(state.hasReachedEnd)")

        // 🔑 다음 페이지 로드 성공
        case .loadMoreSuccess(let newStores, let nextCursor):
            state.stores.append(contentsOf: newStores)  // 기존 데이터에 추가
            state.nextCursor = nextCursor
            state.hasReachedEnd = (nextCursor == nil || nextCursor == "0")
            state.isLoadingMore = false
            state.errorMessage = nil
            print("📝 다음 페이지 추가 완료 - 총 \(state.stores.count)개")
            print("📝 새로운 nextCursor: \(nextCursor ?? "nil")")
            print("📝 hasReachedEnd: \(state.hasReachedEnd)")

        // 🔑 다음 페이지 로드 실패
        case .loadMoreFailed(let message):
            state.errorMessage = message
            state.isLoadingMore = false
            print("📝 다음 페이지 로드 실패: \(message)")
        }
    }
}
