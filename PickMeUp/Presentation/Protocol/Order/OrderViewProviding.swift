//
//  OrderViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 6/15/25.
//

import SwiftUI

protocol OrderViewProviding: AnyObject {
    func makeOrderScreen() -> AnyView
}
