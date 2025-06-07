//
//  StoreListAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

enum StoreListAction {
    enum Intent {
        case onAppear
        case selectCategory(String)
        case togglePickchelin
        case toggleMyPick
        case sortByDistance
        case storeItemOnAppear(storeID: String, imagePaths: [String])
        case loadImage(storeID: String, imagePaths: [String])
        case tapStore(storeID: String)
        // 🔑 페이지네이션 Intent 추가
        case loadNextPage
    }

    enum Result {
        case fetchStores([StorePresentable])
        case fetchFailed(String)
        case loadImageSuccess(storeID: String, images: [UIImage?])
        case loadImageFailed(storeID: String, errorMessage: String)
        // 🔑 페이지네이션 Result 추가
        case fetchStoresWithCursor([StorePresentable], nextCursor: String?)
        case loadMoreSuccess([StorePresentable], nextCursor: String?)
        case loadMoreFailed(String)
    }
}
