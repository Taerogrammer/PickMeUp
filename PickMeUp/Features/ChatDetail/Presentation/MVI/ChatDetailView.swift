//
//  ChatDetailView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatDetailView: View {
    @ObservedObject private var store: ChatDetailStore
    @State private var shouldScrollToBottom = false

    init(chatRoom: ChatRoomEntity, currentUserID: String) {
        self.store = ChatDetailStore(chatRoom: chatRoom, currentUserID: currentUserID)
    }

    var body: some View {
        VStack(spacing: 0) {
            connectionStatusView

            // iOS 버전에 따른 분기 처리
            if #available(iOS 17.0, *) {
                modernMessageListView
            } else {
                legacyMessageListView
            }

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

    // MARK: - iOS 17+ 버전용 (defaultScrollAnchor 사용)
    @available(iOS 17.0, *)
    private var modernMessageListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if store.state.isLoadingHistory {
                    loadingMessagesView
                } else if store.state.messages.isEmpty {
                    emptyMessagesView
                } else {
                    ForEach(store.state.chatViewItems) { item in
                        switch item {
                        case .dateSeparator(let date):
                            DateSeparatorView(date: date)

                        case .message(let message):
                            MessageRow(
                                message: message,
                                isFromCurrentUser: message.sender.userID == store.state.currentUserID
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .defaultScrollAnchor(.bottom)
        .onAppear {
            print("📱 iOS 17+ 모던 스크롤 뷰 사용")
        }
    }

    // MARK: - iOS 16 이하 버전용 (수동 스크롤 제어)
    private var legacyMessageListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if store.state.isLoadingHistory {
                    loadingMessagesView
                } else if store.state.messages.isEmpty {
                    emptyMessagesView
                } else {
                    ForEach(store.state.chatViewItems) { item in
                        switch item {
                        case .dateSeparator(let date):
                            DateSeparatorView(date: date)

                        case .message(let message):
                            MessageRow(
                                message: message,
                                isFromCurrentUser: message.sender.userID == store.state.currentUserID
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                    }

                    // 스크롤 앵커용 투명 뷰
                    if shouldScrollToBottom {
                        Color.clear
                            .frame(height: 1)
                            .id("scrollAnchor")
                            .onAppear {
                                shouldScrollToBottom = false
                            }
                    }
                }
            }
            .padding(.top, 8)
        }
        .onChange(of: store.state.messages.count) { _ in
            triggerScrollToBottom()
        }
        .onChange(of: store.state.isLoadingHistory) { isLoading in
            if !isLoading && !store.state.messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    triggerScrollToBottom()
                }
            }
        }
        .onAppear {
            print("📱 iOS 16 이하 레거시 스크롤 뷰 사용")
            if !store.state.messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    triggerScrollToBottom()
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
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
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
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
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

    // MARK: - Helper Functions
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
    }

    // iOS 16 이하에서 스크롤 트리거
    private func triggerScrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shouldScrollToBottom = true
        }
    }
}
// MARK: - 5. 날짜 유틸리티 확장
extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - 6. 미리보기
#if DEBUG
struct DateSeparatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DateSeparatorView(date: Date())
            DateSeparatorView(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            DateSeparatorView(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
