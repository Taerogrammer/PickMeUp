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
        case loadImage(storeID: String, imagePaths: [String])
        case storeItemOnAppear(storeID: String, imagePaths: [String])
    }

    enum Result {
        case fetchStores([StorePresentable])
        case fetchFailed(String)
        case loadImageSuccess(storeID: String, images: [UIImage?])
        case loadImageFailed(storeID: String, errorMessage: String)
    }
}
