//
//  StoreListAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import Foundation

enum StoreListAction {
  enum Intent {
      /// StoreListView
      case selectCategory(String)
      case onAppear

      /// StoreSectionHeaderView
      case togglePickchelin
      case toggleMyPick
      case sortByDistance
  }

  enum Result {
    case fetchStores([StorePresentable])
    case fetchFailed(String)
  }
}
