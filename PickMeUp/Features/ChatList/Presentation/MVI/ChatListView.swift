//
//  ChatListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject private var store: ChatListStore

    init(store: ChatListStore) {
        self.store = store
    }

    var body: some View {

        ZStack {
            if store.state.isLoading {
                loadingView
            } else if store.state.isEmptyState {
                emptyStateView
            } else {
                chatListContent
            }
        }
        .navigationTitle("채팅")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.startNewChat)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            store.send(.refreshChatList)
        }
        .alert("오류", isPresented: .constant(store.state.errorMessage != nil)) {
            Button("확인") {
                store.send(.dismissError)
            }
        } message: {
            if let errorMessage = store.state.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("채팅 목록을 불러오는 중...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))

            VStack(spacing: 8) {
                Text("아직 채팅방이 없어요")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("새로운 대화를 시작해보세요!")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Button {
                store.send(.startNewChat)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("새 채팅 시작")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Chat List Content
    private var chatListContent: some View {
        List {
            ForEach(store.state.chatRooms) { chatRoom in
                ChatRoomRow(
                    chatRoom: chatRoom,
                    currentUserID: store.state.currentUserID ?? "",
                    onTap: {
                        store.send(.selectChatRoom(chatRoom))
                    }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.vertical, 2)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - ChatRoomRow
struct ChatRoomRow: View {
    let chatRoom: ChatRoomEntity  // Entity로 변경
    let currentUserID: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 프로필 이미지
                profileImageView

                // 채팅 내용
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(opponentName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        if !formattedTime.isEmpty {
                            Text(formattedTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text(lastMessageText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        // 읽지 않은 메시지 배지 (임시)
                        if chatRoom.lastChat == nil {
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }

                // 화살표 아이콘
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(0.6)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Profile Image View
    private var profileImageView: some View {
        AsyncImage(url: opponentProfileImageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(opponentInitial)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Computed Properties
    private var opponent: ParticipantEntity? {
        chatRoom.participants.first { $0.userID != currentUserID }
    }

    private var opponentName: String {
        opponent?.nick ?? "알 수 없는 사용자"
    }

    private var opponentInitial: String {
        let name = opponentName
        return String(name.prefix(1).uppercased())
    }

    private var opponentProfileImageURL: URL? {
        guard let opponent = opponent,
              let profileImage = opponent.profileImage,
              !profileImage.isEmpty else { return nil }

        // 서버 base URL 추가 (실제 서버 URL로 변경 필요)
        let baseURL = "http://pickup.sesac.kr:31668"
        return URL(string: baseURL + profileImage)
    }

    private var lastMessageText: String {
        guard let lastChat = chatRoom.lastChat else {
            return "새로운 채팅방입니다. 첫 메시지를 보내보세요!"
        }

        if !lastChat.content.isEmpty {
            return lastChat.content
        } else if !lastChat.files.isEmpty {
            return "📎 파일 \(lastChat.files.count)개"
        } else {
            return "메시지"
        }
    }

    private var formattedTime: String {
        guard let lastChat = chatRoom.lastChat else { return "" }

        // Entity에서는 이미 Date 타입이므로 바로 사용
        let date = lastChat.createdAt

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            // 오늘: 시간만 표시
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            // 이번 주: 요일 표시
            displayFormatter.dateFormat = "E"
            return displayFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            // 올해: 월/일 표시
            displayFormatter.dateFormat = "M/d"
            return displayFormatter.string(from: date)
        } else {
            // 작년 이전: 년/월/일 표시
            displayFormatter.dateFormat = "yy/M/d"
            return displayFormatter.string(from: date)
        }
    }
}

//#Preview {
//    ChatListView()
//}
