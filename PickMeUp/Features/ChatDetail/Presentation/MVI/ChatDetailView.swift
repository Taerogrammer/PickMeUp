//
//  ChatDetailView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatDetailView: View {
    let chatRoom: ChatRoomEntity
    let currentUserID: String

    @StateObject private var socketManager = ChatSocketManager()
    @StateObject private var messageManager = ChatMessageManager()
    @State private var newMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // 연결 상태 표시
            connectionStatusView

            // 채팅 메시지 목록
            messageListView

            // 메시지 입력 영역
            messageInputView
        }
        .background(Color(hex: "F6EEE3").opacity(0.1))
        .navigationTitle(opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadChatData()
        }
        .onDisappear {
            socketManager.disconnect()
        }
        .alert("오류", isPresented: .constant(messageManager.sendError != nil || messageManager.historyError != nil)) {
            Button("확인") {
                messageManager.sendError = nil
                messageManager.historyError = nil
            }
        } message: {
            if let sendError = messageManager.sendError {
                Text("전송 오류: \(sendError)")
            } else if let historyError = messageManager.historyError {
                Text("채팅 내역 로드 오류: \(historyError)")
            }
        }
    }

    // MARK: - 연결 상태 표시
    private var connectionStatusView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(socketManager.isConnected ? Color(hex: "D7A86E") : Color.gray)
                .frame(width: 8, height: 8)

            Text(socketManager.isConnected ? "온라인" : "오프라인")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if messageManager.isLoadingHistory {
                ProgressView()
                    .scaleEffect(0.8)
                Text("로딩 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if messageManager.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("전송 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8))
    }

    // MARK: - 메시지 목록
    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messageManager.isLoadingHistory {
                        loadingMessagesView
                    } else if messageManager.messages.isEmpty {
                        emptyMessagesView
                    } else {
                        ForEach(messageManager.messages) { message in
                            MessageRow(
                                message: message,
                                isFromCurrentUser: message.sender.userID == currentUserID
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: messageManager.messages.count) { _ in
                if let lastMessage = messageManager.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessage = messageManager.messages.last {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - 로딩 메시지 뷰
    private var loadingMessagesView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "D7A86E"))

            Text("채팅 내역을 불러오는 중...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    // MARK: - 빈 메시지 뷰
    private var emptyMessagesView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "D7A86E").opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "D7A86E"))
            }

            VStack(spacing: 8) {
                Text("대화를 시작해보세요!")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("첫 메시지를 보내보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }

    private var messageInputView: some View {
        HStack(spacing: 12) {
            // 메시지 입력 필드
            TextField("메시지를 입력하세요...", text: $newMessage, axis: .vertical)
                .font(.body)
                .lineLimit(1...3)
                .disabled(messageManager.isLoading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "F6EEE3").opacity(0.8))
                )

            // 전송 버튼
            Button(action: sendMessage) {
                if messageManager.isLoading {
                    ProgressView()
                        .frame(width: 20, height: 20)
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(canSendMessage ? Color(hex: "D7A86E") : Color.gray.opacity(0.5))
            )
            .disabled(!canSendMessage || messageManager.isLoading)
            .scaleEffect(canSendMessage ? 1.0 : 0.9)
            .animation(.easeInOut(duration: 0.2), value: canSendMessage)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }

    // MARK: - Computed Properties
    private var opponentName: String {
        let opponent = chatRoom.participants.first { $0.userID != currentUserID }
        return opponent?.nick ?? "알 수 없는 사용자"
    }

    private var canSendMessage: Bool {
        !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Functions
    private func loadChatData() {
        Task {
            await messageManager.loadChatHistory(roomID: chatRoom.roomID)
            await MainActor.run {
                socketManager.connect(roomID: chatRoom.roomID)
            }
        }
    }

    private func sendMessage() {
        let messageText = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }

        let tempID = "temp_\(UUID().uuidString)"
        let tempMessage = ChatMessageEntity(
            id: tempID,
            roomID: chatRoom.roomID,
            content: messageText,
            createdAt: Date(),
            updatedAt: Date(),
            sender: SenderEntity(
                userID: currentUserID,
                nick: "나",
                profileImage: nil
            ),
            files: []
        )

        messageManager.addMessage(tempMessage)
        newMessage = ""

        Task {
            let success = await messageManager.sendMessage(
                roomID: chatRoom.roomID,
                content: messageText,
                files: nil
            )

            if success {
                await MainActor.run {
                    messageManager.removeMessage(withId: tempID)
                }
            } else {
                await MainActor.run {
                    messageManager.removeMessage(withId: tempID)
                }
            }
        }
    }
}
