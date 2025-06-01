//
//  StoreListRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

struct StoreListRequest {
    var category: String?
    var latitude: Double?
    var longitude: Double?
    var next: String?
    var limit: Int? = 5
    var orderBy: orderType = .distance
}

enum orderType: String {
    case distance
    case orders
    case reviews
}
