//
//  StoreDetailAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

enum StoreDetailAction {
    enum Intent {
        case onAppear
        case selectCategory(String)
        case tapNavigation
        case tapPay
        case tapBack
        case tapLike
    }

    enum Result {
        case fetchedStoreDetail(StoreDetailResponse)
    }
}
