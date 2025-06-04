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
            state.isLiked.toggle()
        case .tapBack: break
            // 보통은 라우터에 pop을 보내는 구조
        default:
            break
        }
    }

    func reduce(state: inout StoreDetailState, result: StoreDetailAction.Result) {
        switch result {
        case .fetchedStoreDetail(let response):
            let converted = response.toState()
            state.name = converted.name
            state.isPickchelin = converted.isPickchelin
            state.likeCount = converted.likeCount
            state.rating = converted.rating
            state.address = converted.address
            state.openHour = converted.openHour
            state.parkingAvailable = converted.parkingAvailable
            state.estimatedTime = converted.estimatedTime
            state.distance = converted.distance
            state.categories = converted.categories
            state.menus = converted.menus
            state.images = converted.images
        }
    }
}
