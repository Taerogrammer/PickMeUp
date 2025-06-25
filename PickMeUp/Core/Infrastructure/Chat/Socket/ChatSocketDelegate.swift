//
//  ChatSocketDelegate.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

protocol ChatSocketDelegate: AnyObject {
    func socketDidConnect()
    func socketDidDisconnect()
    func socketDidReceiveError(_ error: String)
    func socketDidReceiveMessage(_ message: ChatMessageEntity)
}
