//
//  ChatRoom.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatRoomRow: View {
    let chatRoom: ChatRoomEntity
    let currentUserID: String
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 프로필 이미지
                profileImageView

                // 채팅 내용
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(opponentName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        if !formattedTime.isEmpty {
                            Text(formattedTime)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text(lastMessageText)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        // 읽지 않은 메시지 배지
                        if chatRoom.lastChat == nil {
                            Text("NEW")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.1 : 0.05),
                        radius: isPressed ? 8 : 12,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        } perform: {
            // 길게 눌렀을 때의 액션 (필요시 추가)
        }
    }

    // MARK: - 프로필 이미지
    private var profileImageView: some View {
        AsyncImage(url: opponentProfileImageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: profileGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(opponentInitial)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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

    private var profileGradientColors: [Color] {
        // 이름에 따라 다른 그라데이션 색상 생성
        let colors: [[Color]] = [
            [Color.orange.opacity(0.8), Color.orange],
            [Color.blue.opacity(0.8), Color.blue],
            [Color.green.opacity(0.8), Color.green],
            [Color.purple.opacity(0.8), Color.purple],
            [Color.pink.opacity(0.8), Color.pink],
            [Color.red.opacity(0.8), Color.red]
        ]

        let hash = abs(opponentName.hashValue)
        return colors[hash % colors.count]
    }

    private var opponentProfileImageURL: URL? {
        guard let opponent = opponent,
              let profileImage = opponent.profileImage,
              !profileImage.isEmpty else { return nil }

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

        let date = lastChat.createdAt
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            displayFormatter.dateFormat = "E"
            return displayFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            displayFormatter.dateFormat = "M/d"
            return displayFormatter.string(from: date)
        } else {
            displayFormatter.dateFormat = "yy/M/d"
            return displayFormatter.string(from: date)
        }
    }
}
