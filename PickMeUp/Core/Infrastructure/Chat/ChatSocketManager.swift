//
//  ChatSocketManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

final class ChatSocketManager: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?

    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private let baseURL = "ws://pickup.sesac.kr:31668"

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // 소켓 연결
    func connect(roomID: String) {
        disconnect() // 기존 연결 해제

        guard let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue),
              let sesacKey = Bundle.main.object(forInfoDictionaryKey: "SeSACKey") as? String else {
            DispatchQueue.main.async {
                self.connectionError = "인증 정보가 없습니다."
            }
            return
        }

        // WebSocket URL 구성
        let socketURLString = "\(baseURL)/chats-\(roomID)"
        guard let socketURL = URL(string: socketURLString) else {
            DispatchQueue.main.async {
                self.connectionError = "잘못된 소켓 URL입니다."
            }
            return
        }

        // URLRequest 생성 및 헤더 설정
        var request = URLRequest(url: socketURL)
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        request.setValue(sesacKey, forHTTPHeaderField: "SeSACKey")

        // WebSocket 연결 생성
        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // 메시지 수신 시작
        receiveMessage()

        print("🔌 Attempting to connect to: \(socketURLString)")
    }

    // 소켓 해제
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionError = nil
        }

        print("🔌 Socket disconnected")
    }

    // 메시지 수신
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received text: \(text)")
                    self?.handleReceivedMessage(text)
                case .data(let data):
                    print("📨 Received data: \(data)")
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleReceivedMessage(text)
                    }
                @unknown default:
                    print("📨 Unknown message type")
                }

                // 다음 메시지 수신을 위해 재귀 호출
                self?.receiveMessage()

            case .failure(let error):
                print("🚨 WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionError = "메시지 수신 오류: \(error.localizedDescription)"
                    self?.isConnected = false
                }
            }
        }
    }

    // 수신된 메시지 처리
    private func handleReceivedMessage(_ message: String) {
        // JSON 파싱하여 채팅 메시지 처리
        guard let data = message.data(using: .utf8) else { return }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📨 Parsed message: \(json)")

                // 연결 확인 메시지인지 체크
                if let event = json["event"] as? String, event == "connected" {
                    DispatchQueue.main.async {
                        self.isConnected = true
                        self.connectionError = nil
                    }
                }

                // 채팅 메시지인지 체크
                if let chatData = json["chat_id"] as? String {
                    // TODO: 채팅 메시지 처리
                    print("💬 Chat message received: \(json)")
                }
            }
        } catch {
            print("🚨 JSON parsing error: \(error)")
        }
    }

    // 메시지 전송 (나중에 사용)
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("🚨 Send error: \(error)")
            } else {
                print("📤 Message sent successfully")
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension ChatSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected successfully")
        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionError = nil
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("❌ WebSocket disconnected with code: \(closeCode)")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}
