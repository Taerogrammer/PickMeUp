//
//  StoreViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

protocol StoreViewProviding: AnyObject {
    func makeStoreScreen() -> AnyView
}
