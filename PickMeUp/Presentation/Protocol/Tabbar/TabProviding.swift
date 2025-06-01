//
//  TabProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

protocol TabProviding: AnyObject {
    func makeTabbarScreen() -> AnyView
}
