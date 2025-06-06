//
//  StoreDetailAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

enum StoreDetailAction {
    enum Intent {
        case onAppear
        case selectCategory(String)
        case tapNavigation
        case tapPay
        case tapBack
        case tapLike
        case loadMenuImages(items: [StoreMenuItemEntity])
    }

    enum Result {
        case fetchedStoreDetail(StoreDetailResponse)
        case loadMenuImageSuccess(menuID: String, image: UIImage)
        case loadMenuImageFailed(menuID: String, errorMessage: String)
    }
}
