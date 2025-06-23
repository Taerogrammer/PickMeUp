//
//  ChattingViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

protocol ChattingViewProviding: AnyObject {
    func makeChattingScreen() -> AnyView
}
