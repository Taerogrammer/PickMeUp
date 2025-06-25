//
//  MessageRow.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct MessageRow: View {
    let message: ChatMessageEntity
    let isFromCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom) {
            if isFromCurrentUser {
                Spacer(minLength: 50)
                myMessageBubble
            } else {
                otherMessageBubble
                Spacer(minLength: 50)
            }
        }
    }

    private var myMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .bottom, spacing: 6) {
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(message.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "D7A86E"))
                    .clipShape(MessageBubbleShape(isFromCurrentUser: true))
            }
        }
    }

    private var otherMessageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                // 프로필 이미지
                Circle()
                    .fill(Color(hex: "F6EEE3"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(message.sender.nick.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "D7A86E"))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(message.sender.nick)
                        .font(.caption)
                        .foregroundColor(Color(hex: "D7A86E"))
                        .fontWeight(.medium)

                    HStack(alignment: .bottom, spacing: 6) {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(MessageBubbleShape(isFromCurrentUser: false))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "F6EEE3"), lineWidth: 1)
                            )

                        Text(formattedTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: message.createdAt)
    }
}
