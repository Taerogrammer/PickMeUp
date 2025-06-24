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
            Color.gray15
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 커스텀 헤더
                headerView

                // 메인 컨텐츠
                mainContent
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

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("채팅")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if !store.state.chatRooms.isEmpty {
                        Text("\(store.state.chatRooms.count)개의 대화")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button {
                    store.send(.startNewChat)
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.8), Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)

            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 0.5)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - 메인 컨텐츠
    private var mainContent: some View {
        Group {
            if store.state.isLoading {
                loadingView
            } else if store.state.isEmptyState {
                emptyStateView
            } else {
                chatListContent
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: true)
            }

            Text("채팅 목록을 불러오는 중...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange.opacity(0.7))
                }

                VStack(spacing: 12) {
                    Text("아직 채팅방이 없어요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("새로운 대화를 시작해보세요!\n맛있는 음식을 나누며 친구를 만들어보아요 🍰")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Button {
                store.send(.startNewChat)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("새 채팅 시작")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.8), Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: Color.orange.opacity(0.3), radius: 12, x: 0, y: 6)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    // MARK: - 채팅 목록
    private var chatListContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.state.chatRooms) { chatRoom in
                    ChatRoomRow(
                        chatRoom: chatRoom,
                        currentUserID: store.state.currentUserID ?? "",
                        onTap: {
                            store.send(.selectChatRoom(chatRoom))
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                }
            }
            .padding(.top, 8)
        }
    }
}

//#Preview {
//    ChatListView()
//}
