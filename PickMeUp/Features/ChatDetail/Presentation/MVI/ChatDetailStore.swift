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

    init(
        chatRoom: ChatRoomEntity,
        currentUserID: String,
        messageManager: ChatMessageManager = ChatMessageManager(),
        socketManager: ChatSocketManager = ChatSocketManager()
    ) {
        self.state = ChatDetailState(chatRoom: chatRoom, currentUserID: currentUserID)
        self.messageManager = messageManager
        self.socketManager = socketManager

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

    private var cancellables = Set<AnyCancellable>()
}
