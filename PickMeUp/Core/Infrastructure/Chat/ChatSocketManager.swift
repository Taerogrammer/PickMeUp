//
//  ChatSocketManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import UIKit

final class ChatSocketManager: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    private var currentRoomID: String?
    private var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 5

    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private let baseURL = APIEnvironment.production.webSocketBaseURL

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // 앱 라이프사이클 관찰
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopHeartbeat()
        stopReconnectTimer()
    }

    // 소켓 연결
    func connect(roomID: String) {
        currentRoomID = roomID
        disconnect() // 기존 연결 해제

        let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue)
        let sesacKey = APIConstants.Headers.Values.sesacKeyValue()

        print("🔍 [Socket Debug] AccessToken 존재: \(accessToken != nil)")
        print("🔍 [Socket Debug] SeSACKey 존재: \(!sesacKey.isEmpty)")

        guard let accessToken = accessToken,
              !sesacKey.isEmpty else {
            print("🚨 [Socket Debug] 인증 정보 누락!")
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

        // 타임아웃 설정
        request.timeoutInterval = 30

        // WebSocket 연결 생성
        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // 메시지 수신 시작
        receiveMessage()

        print("🔌 Attempting to connect to: \(socketURLString)")
    }

    // 재연결
    func reconnect() {
        guard let roomID = currentRoomID else {
            print("🚨 재연결할 roomID가 없습니다.")
            return
        }

        guard reconnectAttempts < maxReconnectAttempts else {
            print("🚨 최대 재연결 시도 횟수 초과")
            DispatchQueue.main.async {
                self.connectionError = "연결에 실패했습니다. 나중에 다시 시도해주세요."
            }
            return
        }

        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0) // Exponential backoff

        print("🔄 \(delay)초 후 재연결 시도... (\(reconnectAttempts)/\(maxReconnectAttempts))")

        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            self.connect(roomID: roomID)
        }
    }

    // 소켓 해제
    func disconnect() {
        stopHeartbeat()
        stopReconnectTimer()

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
                self?.resetReconnectAttempts() // 성공적으로 메시지 받으면 재연결 카운터 리셋

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
                self?.handleConnectionError(error)
            }
        }
    }

    // 연결 오류 처리
    private func handleConnectionError(_ error: Error) {
        let nsError = error as NSError

        DispatchQueue.main.async {
            self.isConnected = false

            // 네트워크 연결 오류인 경우 재연결 시도
            if nsError.code == NSURLErrorNetworkConnectionLost ||
               nsError.code == NSURLErrorTimedOut ||
               nsError.code == NSURLErrorCannotConnectToHost {

                self.connectionError = "연결이 끊어졌습니다. 재연결 중..."
                self.reconnect()
            } else {
                self.connectionError = "연결 오류: \(error.localizedDescription)"
            }
        }
    }

    // 수신된 메시지 처리
    private func handleReceivedMessage(_ message: String) {
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
                    startHeartbeat() // 연결 성공 시 heartbeat 시작
                }

                // 채팅 메시지인지 체크
                if let chatData = json["chat_id"] as? String {
                    print("💬 Chat message received: \(json)")
                    // TODO: 새 메시지를 ChatDetailStore에 전달
                }
            }
        } catch {
            print("🚨 JSON parsing error: \(error)")
        }
    }

    // 메시지 전송
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

    // Heartbeat 시작
    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.sendPing()
        }
    }

    // Heartbeat 중지
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    // Ping 메시지 전송
    private func sendPing() {
        let pingMessage = URLSessionWebSocketTask.Message.string("{\"type\":\"ping\"}")
        webSocketTask?.send(pingMessage) { error in
            if let error = error {
                print("🚨 Ping failed: \(error)")
                self.handleConnectionError(error)
            }
        }
    }

    // 재연결 타이머 중지
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }

    // 재연결 시도 횟수 리셋
    private func resetReconnectAttempts() {
        reconnectAttempts = 0
    }

    // 앱 라이프사이클 핸들러
    @objc private func appDidEnterBackground() {
        print("📱 앱이 백그라운드로 이동 - 소켓 연결 유지")
        // 필요시 연결 해제: disconnect()
    }

    @objc private func appWillEnterForeground() {
        print("📱 앱이 포그라운드로 복귀 - 연결 상태 확인")
        if !isConnected, let roomID = currentRoomID {
            connect(roomID: roomID)
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
        resetReconnectAttempts()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("❌ WebSocket disconnected with code: \(closeCode)")
        DispatchQueue.main.async {
            self.isConnected = false
        }

        stopHeartbeat()

        // 정상적인 종료가 아닌 경우 재연결 시도
        if closeCode != .goingAway && closeCode != .normalClosure {
            reconnect()
        }
    }
}
