//
//  StoreListIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

enum StoreListIntent {

    /// StoreListView
    case selectCategory(String)
    case onAppear
    case fetchStores([StorePresentable])
    case fetchFailed(String)

    /// StoreSectionHeaderView
    case togglePickchelin
    case toggleMyPick
    case sortByDistance
}
