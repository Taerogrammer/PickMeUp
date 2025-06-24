//
//  ChatSocketManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SocketIO
import Foundation

protocol ChatSocketDelegate: AnyObject {
    func socketDidConnect()
    func socketDidDisconnect()
    func socketDidReceiveError(_ error: String)
    func socketDidReceiveMessage(_ message: ChatMessageEntity)
}

final class ChatSocketManager: ObservableObject {
    weak var delegate: ChatSocketDelegate?
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private let baseURL = APIEnvironment.production.baseURL

    // Socket.IO 연결
    func connect(roomID: String) {
        disconnect() // 기존 연결 해제

        guard let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue) else {
            connectionError = "AccessToken이 없습니다."
            return
        }

        let sesacKey = APIConstants.Headers.Values.sesacKeyValue()
        guard !sesacKey.isEmpty else {
            connectionError = "SeSACKey가 없습니다."
            return
        }

        // 1. SocketManager 생성
        guard let url = URL(string: baseURL) else {
            connectionError = "잘못된 URL입니다."
            return
        }

        // 2. Socket.IO 설정
        let config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .extraHeaders([
                "Authorization": accessToken,
                "SeSACKey": sesacKey
            ]),
            .path("/socket.io/"), // Socket.IO 기본 path
            .connectParams(["room_id": roomID]) // 필요시 추가 파라미터
        ]

        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.socket(forNamespace: "/chats-\(roomID)") // 네임스페이스 설정

        setupSocketEvents()

        // 3. 연결 시작
        socket?.connect()

        print("🔌 Socket.IO 연결 시도: \(baseURL)/chats-\(roomID)")
    }

    // 연결 해제
    func disconnect() {
        socket?.disconnect()
        socket = nil
        manager = nil

        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionError = nil
        }

        print("🔌 Socket.IO 연결 해제")
    }

    // 메시지 전송 (Socket.IO emit)
    func sendMessage(_ message: String) {
        socket?.emit("chat", message) {
            print("📤 메시지 전송 완료")
        }
    }

    private func handleChatMessage(_ data: [Any]) {
        guard let messageData = data.first as? [String: Any] else {
            print("🚨 잘못된 메시지 형식")
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let messageResponse = try decoder.decode(ChatSendResponse.self, from: jsonData)
            let messageEntity = messageResponse.toEntity()

            // 델리게이트를 통해 메시지 전달
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.socketDidReceiveMessage(messageEntity)
            }

            print("✅ 실시간 메시지 수신: \(messageEntity.content)")
        } catch {
            print("🚨 메시지 파싱 실패: \(error)")
        }
    }

    private func setupSocketEvents() {
        // 연결 이벤트
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket.IO 연결 성공: \(data)")
            DispatchQueue.main.async {
                self?.isConnected = true
                self?.connectionError = nil
                self?.delegate?.socketDidConnect()
            }
        }

        // 연결 해제 이벤트
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("❌ Socket.IO 연결 해제: \(data)")
            DispatchQueue.main.async {
                self?.isConnected = false
                self?.delegate?.socketDidDisconnect()
            }
        }

        // 오류 이벤트
        socket?.on(clientEvent: .error) { [weak self] data, ack in
            print("🚨 Socket.IO 오류: \(data)")
            DispatchQueue.main.async {
                self?.connectionError = "소켓 오류: \(data)"
                self?.isConnected = false
                self?.delegate?.socketDidReceiveError("소켓 오류: \(data)")
            }
        }

        // 채팅 메시지 수신 - 문서에 명시된 "chat" 이벤트
        socket?.on("chat") { [weak self] data, ack in
            print("💬 채팅 메시지 수신: \(data)")
            self?.handleChatMessage(data)
        }

        // 연결 상태 이벤트
        socket?.on(clientEvent: .statusChange) { data, ack in
            print("📡 연결 상태 변경: \(data)")
        }
    }
}
