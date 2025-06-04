//
//  StoreDetailViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

protocol StoreDetailViewProviding: AnyObject {
    func makeStoreDetailScreen(storeID: String) -> AnyView
}
