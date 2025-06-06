//
//  StoreImageCarouselEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreImageCarouselEntity {
    let imageURLs: [String]
    var isLiked: Bool
    let loadedImages: [String: UIImage]
    let isLikeLoading: Bool
}
