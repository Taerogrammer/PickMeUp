//
//  TimelineComponents.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct TimelineNode: View {
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.deepSprout : Color.gray15)
                .frame(width: 20, height: 20)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .shadow(color: isCompleted ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
    }
}

struct TimelineConnector: View {
    let isCompleted: Bool

    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.deepSprout : Color.gray15)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
}

struct TimelineLabel: View {
    let timeline: OrderStatusTimelineEntity

    var body: some View {
        VStack(spacing: 4) {
            Text(OrderStatusHelper.getDisplayName(timeline.status))
                .font(.pretendardCaption1)
                .fontWeight(timeline.completed ? .semibold : .regular)
                .foregroundColor(timeline.completed ? .gray90 : .gray45)
                .multilineTextAlignment(.center)

            if let changedAt = timeline.changedAt, timeline.completed {
                Text(DateFormattingHelper.formatTime(changedAt))
                    .font(.pretendardCaption2)
                    .foregroundColor(.deepSprout)
                    .fontWeight(.medium)
            }
        }
    }
}
