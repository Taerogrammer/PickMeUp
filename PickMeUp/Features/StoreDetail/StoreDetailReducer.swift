//
//  StoreDetailReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

struct StoreDetailReducer {
    func reduce(state: inout StoreDetailState, action: StoreDetailAction.Intent) {
        switch action {
        case .selectCategory(let category):
            state.selectedCategory = category
        case .tapLike:
            // 따로 isLiked 상태를 두고 싶다면 state.isLiked.toggle() 등으로 처리 가능
            break
        case .tapBack: break
        default: break
        }
    }

    func reduce(state: inout StoreDetailState, result: StoreDetailAction.Result) {
        switch result {
        case .fetchedStoreDetail(let response):
            state = response.toState() // 💡 response를 변환한 결과로 교체
        }
    }
}
