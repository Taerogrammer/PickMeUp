//
//  ChatDetailView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatDetailView: View {
    @ObservedObject private var store: ChatDetailStore

    init(chatRoom: ChatRoomEntity, currentUserID: String) {
        self.store = ChatDetailStore(chatRoom: chatRoom, currentUserID: currentUserID)
    }

    var body: some View {
        VStack(spacing: 0) {
            connectionStatusView
            messageListView
            messageInputView
        }
        .background(Color(hex: "F6EEE3").opacity(0.1))
        .navigationTitle(store.state.opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .alert("오류", isPresented: .constant(store.state.hasError)) {
            Button("확인") {
                store.send(.dismissError)
            }
        } message: {
            Text(store.state.errorText)
        }
    }

    // MARK: - 연결 상태 표시
    private var connectionStatusView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(store.state.isSocketConnected ? Color(hex: "D7A86E") : Color.gray)
                .frame(width: 8, height: 8)

            Text(store.state.isSocketConnected ? "온라인" : "오프라인")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if store.state.isLoadingHistory {
                ProgressView()
                    .scaleEffect(0.8)
                Text("로딩 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if store.state.isLoading {
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
                    if store.state.isLoadingHistory {
                        loadingMessagesView
                    } else if store.state.messages.isEmpty {
                        emptyMessagesView
                    } else {
                        ForEach(store.state.messages) { message in
                            MessageRow(
                                message: message,
                                isFromCurrentUser: message.sender.userID == store.state.currentUserID
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: store.state.messages.count) { _ in
                if let lastMessage = store.state.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessage = store.state.messages.last {
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
            TextField("메시지를 입력하세요...", text: .init(
                get: { store.state.newMessage },
                set: { store.send(.updateNewMessage($0)) }
            ), axis: .vertical)
            .font(.body)
            .lineLimit(1...3)
            .disabled(store.state.isLoading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "F6EEE3").opacity(0.8))
            )

            Button(action: sendMessage) {
                if store.state.isLoading {
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
                    .fill(store.state.canSendMessage ? Color(hex: "D7A86E") : Color.gray.opacity(0.5))
            )
            .disabled(!store.state.canSendMessage)
            .scaleEffect(store.state.canSendMessage ? 1.0 : 0.9)
            .animation(.easeInOut(duration: 0.2), value: store.state.canSendMessage)
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

    // MARK: - Functions
    private func sendMessage() {
        let messageText = store.state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }

        // 임시 메시지 생성
        let tempID = "temp_\(UUID().uuidString)"
        let tempMessage = ChatMessageEntity(
            id: tempID,
            roomID: store.state.chatRoom.roomID,
            content: messageText,
            createdAt: Date(),
            updatedAt: Date(),
            sender: SenderEntity(
                userID: store.state.currentUserID,
                nick: "나",
                profileImage: nil
            ),
            files: []
        )

        // 임시 메시지 추가
        store.send(.addTempMessage(tempMessage))

        // 실제 메시지 전송
        store.send(.sendMessage(messageText))

        // 전송 실패 시 임시 메시지 제거는 Effect에서 처리
    }
}
