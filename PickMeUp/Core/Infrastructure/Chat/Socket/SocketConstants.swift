//
//  SocketConstants.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

enum SocketConstants {
    static let socketPath = "/socket.io/"
    static let chatEvent = "chat"
    static let namespacePrefix = "/chats-"

    enum LogMessages {
        static let connectAttempt = "🔌 Socket.IO 연결 시도"
        static let connectSuccess = "✅ Socket.IO 연결 성공"
        static let disconnect = "❌ Socket.IO 연결 해제"
        static let error = "🚨 Socket.IO 오류"
        static let messageReceived = "💬 채팅 메시지 수신"
        static let messageSuccess = "✅ 실시간 메시지 수신"
        static let messageFailed = "🚨 메시지 파싱 실패"
        static let sendComplete = "📤 메시지 전송 완료"
        static let disconnectComplete = "🔌 Socket.IO 연결 해제"
    }

    enum ErrorMessages {
        static let noAccessToken = "AccessToken이 없습니다."
        static let noSesacKey = "SeSACKey가 없습니다."
        static let invalidURL = "잘못된 URL입니다."
        static let invalidMessageFormat = "🚨 잘못된 메시지 형식"
        static let socketNotConnected = "🚨 Socket이 연결되지 않음"
    }
}
