//
//  ChatDetailStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Combine
import Foundation

final class ChatDetailStore: ObservableObject {
    @Published private(set) var state: ChatDetailState

    private let messageManager: ChatMessageManager
    private let socketManager: ChatSocketManager
    private var cancellables = Set<AnyCancellable>()

    init(
        chatRoom: ChatRoomEntity,
        currentUserID: String,
        messageManager: ChatMessageManager = ChatMessageManager(),
        socketManager: ChatSocketManager = ChatSocketManager()
    ) {
        self.state = ChatDetailState(chatRoom: chatRoom, currentUserID: currentUserID)
        self.messageManager = messageManager
        self.socketManager = socketManager

        // 델리게이트 설정 - 실시간 메시지 수신을 위해 필수!
        socketManager.delegate = self

        setupManagerObservation()
    }

    @MainActor
    func send(_ intent: ChatDetailAction.Intent) {
        ChatDetailReducer.reduce(state: &state, intent: intent)

        Task {
            if let result = await ChatDetailEffect.handle(
                intent: intent,
                state: state,
                messageManager: messageManager,
                socketManager: socketManager
            ) {
                handleResult(result)
            }
        }
    }

    @MainActor
    private func handleResult(_ result: ChatDetailAction.Result) {
        ChatDetailReducer.reduce(state: &state, result: result)
    }

    // Manager들의 상태 변화를 관찰하여 State에 반영
    private func setupManagerObservation() {
        // MessageManager 관찰
        messageManager.$messages
            .sink { [weak self] messages in
                Task { @MainActor in
                    self?.state.messages = messages.sorted { $0.createdAt < $1.createdAt }
                }
            }
            .store(in: &cancellables)

        messageManager.$isLoading
            .sink { [weak self] isLoading in
                Task { @MainActor in
                    self?.state.isLoading = isLoading
                }
            }
            .store(in: &cancellables)

        messageManager.$isLoadingHistory
            .sink { [weak self] isLoadingHistory in
                Task { @MainActor in
                    self?.state.isLoadingHistory = isLoadingHistory
                }
            }
            .store(in: &cancellables)

        messageManager.$sendError
            .sink { [weak self] error in
                Task { @MainActor in
                    self?.state.sendError = error
                }
            }
            .store(in: &cancellables)

        messageManager.$historyError
            .sink { [weak self] error in
                Task { @MainActor in
                    self?.state.historyError = error
                }
            }
            .store(in: &cancellables)

        // SocketManager 관찰
        socketManager.$isConnected
            .sink { [weak self] isConnected in
                Task { @MainActor in
                    self?.state.isSocketConnected = isConnected
                }
            }
            .store(in: &cancellables)

        socketManager.$connectionError
            .sink { [weak self] error in
                Task { @MainActor in
                    self?.state.errorMessage = error
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - ChatSocketDelegate 구현 (실시간 메시지의 핵심!)
extension ChatDetailStore: ChatSocketDelegate {
    func socketDidConnect() {
        print("🔗 Store: Socket 연결됨")
        // 연결 상태는 이미 @Published 프로퍼티로 관찰되고 있음
    }

    func socketDidDisconnect() {
        print("🔗 Store: Socket 연결 해제됨")
        // 연결 상태는 이미 @Published 프로퍼티로 관찰되고 있음
    }

    func socketDidReceiveError(_ error: String) {
        print("🚨 Store: Socket 에러: \(error)")
        Task { @MainActor in
            handleResult(.socketError(error))
        }
    }

    func socketDidReceiveMessage(_ message: ChatMessageEntity) {
        print("💬 Store: 실시간 메시지 수신: \(message.content)")
        // 실시간으로 받은 메시지를 State에 반영
        Task { @MainActor in
            send(.receiveRealtimeMessage(message))
        }
    }
}
