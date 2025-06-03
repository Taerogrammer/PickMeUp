//
//  StoreListIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

enum StoreListIntent {
    case onAppear
    case fetchStores([StorePresentable])
    case fetchFailed(String)
    case togglePickchelin
    case toggleMyPick
    case selectCategory(String)
}
