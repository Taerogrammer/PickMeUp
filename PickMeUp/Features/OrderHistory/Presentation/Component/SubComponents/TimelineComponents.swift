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
        Circle()
            .fill(isCompleted ? Color.deepSprout : Color.gray30)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .opacity(isCompleted ? 1 : 0)
            )
    }
}

struct TimelineConnector: View {
    let isCompleted: Bool

    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.deepSprout : Color.gray30)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
}

struct TimelineLabel: View {
   let timeline: OrderStatusTimelineEntity

   var body: some View {
       VStack(spacing: 2) {
           Text(OrderStatusHelper.getDisplayName(timeline.status))
               .font(.pretendardCaption2)
               .fontWeight(timeline.completed ? .semibold : .regular)
               .foregroundColor(timeline.completed ? .deepSprout : .gray60)
               .multilineTextAlignment(.center)

           Group {
               if let changedAt = timeline.changedAt {
                   Text(DateFormattingHelper.formatTime(changedAt))
                       .font(.pretendardCaption3)
                       .foregroundColor(.gray45)
               } else {
                   Text(" ")
                       .font(.pretendardCaption3)
                       .foregroundColor(.clear)
               }
           }
       }
   }
}
