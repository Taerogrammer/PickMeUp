//
//  ChatDetailViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

protocol ChatDetailViewProviding: AnyObject {
    func makeChatDetailScreen(chatRoom: String, userID: String) -> AnyView
}
