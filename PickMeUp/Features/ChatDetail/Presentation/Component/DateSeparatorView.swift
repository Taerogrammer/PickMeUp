//
//  DateSeparatorView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import SwiftUI

struct DateSeparatorView: View {
    let date: Date

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)

            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        if Calendar.current.isDateInToday(date) {
            return "오늘"
        } else if Calendar.current.isDateInYesterday(date) {
            return "어제"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "M월 d일 EEEE"
        } else {
            formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        }

        return formatter.string(from: date)
    }
}

// MARK: - 2. 메시지와 날짜를 포함하는 뷰 아이템
enum ChatViewItem: Identifiable {
    case dateSeparator(Date)
    case message(ChatMessageEntity)

    var id: String {
        switch self {
        case .dateSeparator(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "date_\(formatter.string(from: date))"
        case .message(let message):
            return message.id
        }
    }
}
