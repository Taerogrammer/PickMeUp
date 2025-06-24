//
//  ChatSocketManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SocketIO
import Foundation

final class ChatSocketManager: ObservableObject {

    // MARK: - Properties
    weak var delegate: ChatSocketDelegate?
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private let baseURL = APIEnvironment.production.baseURL

    // MARK: - Public Methods
    func connect(roomID: String) {
        disconnect()

        guard let config = validateConfiguration(roomID: roomID) else { return }
        setupSocket(roomID: roomID, config: config)
    }

    func disconnect() {
        cleanupSocket()
        updateConnectionState(connected: false)
        print(SocketConstants.LogMessages.disconnectComplete)
    }

    func sendMessage(_ message: String) {
        guard isConnected else {
            print(SocketConstants.ErrorMessages.socketNotConnected)
            return
        }

        socket?.emit(SocketConstants.chatEvent, message) {
            print(SocketConstants.LogMessages.sendComplete)
        }
    }

    // MARK: - Private Methods - Configuration
    private func validateConfiguration(roomID: String) -> (accessToken: String, sesacKey: String, url: URL)? {
        guard let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue) else {
            connectionError = SocketConstants.ErrorMessages.noAccessToken
            return nil
        }

        let sesacKey = APIConstants.Headers.Values.sesacKeyValue()
        guard !sesacKey.isEmpty else {
            connectionError = SocketConstants.ErrorMessages.noSesacKey
            return nil
        }

        guard let url = URL(string: baseURL) else {
            connectionError = SocketConstants.ErrorMessages.invalidURL
            return nil
        }

        return (accessToken, sesacKey, url)
    }

    private func setupSocket(roomID: String, config: (accessToken: String, sesacKey: String, url: URL)) {
        let socketConfig: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .extraHeaders([
                "Authorization": config.accessToken,
                "SeSACKey": config.sesacKey
            ]),
            .path(SocketConstants.socketPath),
            .connectParams(["room_id": roomID])
        ]

        manager = SocketManager(socketURL: config.url, config: socketConfig)
        socket = manager?.socket(forNamespace: "\(SocketConstants.namespacePrefix)\(roomID)")

        setupSocketEvents()
        socket?.connect()

        print("\(SocketConstants.LogMessages.connectAttempt): \(baseURL)\(SocketConstants.namespacePrefix)\(roomID)")
    }

    private func cleanupSocket() {
        socket?.disconnect()
        socket?.removeAllHandlers()
        socket = nil
        manager = nil
    }

    private func updateConnectionState(connected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = connected
            if !connected {
                self.connectionError = nil
            }
        }
    }
}

// MARK: - Socket Events Extension
extension ChatSocketManager {

    private func setupSocketEvents() {
        setupConnectionEvents()
        setupMessageEvents()
        setupStatusEvents()
    }

    private func setupConnectionEvents() {
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("\(SocketConstants.LogMessages.connectSuccess): \(data)")
            self?.handleConnectionSuccess()
        }

        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("\(SocketConstants.LogMessages.disconnect): \(data)")
            self?.handleDisconnection()
        }

        socket?.on(clientEvent: .error) { [weak self] data, ack in
            print("\(SocketConstants.LogMessages.error): \(data)")
            self?.handleConnectionError("소켓 오류: \(data)")
        }
    }

    private func setupMessageEvents() {
        socket?.on(SocketConstants.chatEvent) { [weak self] data, ack in
            print("\(SocketConstants.LogMessages.messageReceived): \(data)")
            self?.handleChatMessage(data)
        }
    }

    private func setupStatusEvents() {
        socket?.on(clientEvent: .statusChange) { data, ack in
            print("📡 연결 상태 변경: \(data)")
        }
    }
}

// MARK: - Event Handlers Extension
extension ChatSocketManager {

    private func handleConnectionSuccess() {
        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionError = nil
            self.delegate?.socketDidConnect()
        }
    }

    private func handleDisconnection() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.delegate?.socketDidDisconnect()
        }
    }

    private func handleConnectionError(_ error: String) {
        DispatchQueue.main.async {
            self.connectionError = error
            self.isConnected = false
            self.delegate?.socketDidReceiveError(error)
        }
    }
}

// MARK: - Message Handling Extension
extension ChatSocketManager {

    private func handleChatMessage(_ data: [Any]) {
        guard let messageData = extractMessageData(from: data) else { return }

        do {
            let messageEntity = try parseMessage(from: messageData)
            notifyMessageReceived(messageEntity)
            print("\(SocketConstants.LogMessages.messageSuccess): \(messageEntity.content)")
        } catch {
            print("\(SocketConstants.LogMessages.messageFailed): \(error)")
        }
    }

    private func extractMessageData(from data: [Any]) -> [String: Any]? {
        guard let messageData = data.first as? [String: Any] else {
            print(SocketConstants.ErrorMessages.invalidMessageFormat)
            return nil
        }
        return messageData
    }

    private func parseMessage(from messageData: [String: Any]) throws -> ChatMessageEntity {
        let jsonData = try JSONSerialization.data(withJSONObject: messageData)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let messageResponse = try decoder.decode(ChatSendResponse.self, from: jsonData)
        return messageResponse.toEntity()
    }

    private func notifyMessageReceived(_ message: ChatMessageEntity) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.socketDidReceiveMessage(message)
        }
    }
}

// MARK: - Debug Extension
extension ChatSocketManager {
    func getDebugInfo() -> [String: Any] {
        return [
            "isConnected": isConnected,
            "hasError": connectionError != nil,
            "errorMessage": connectionError ?? "none",
            "socketExists": socket != nil,
            "managerExists": manager != nil
        ]
    }
}
