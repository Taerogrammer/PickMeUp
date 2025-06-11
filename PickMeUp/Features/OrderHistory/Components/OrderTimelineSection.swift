//
//  OrderTimelineSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderTimelineSection: View {
    let orderData: OrderDataEntity

    private var filteredTimeline: [OrderStatusTimelineEntity] {
        orderData.orderStatusTimeline.filter { $0.status != "PICKED_UP" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "clock.fill", title: "진행 상황")

            VStack(spacing: 16) {
                // 타임라인 점들과 연결선
                HStack(spacing: 0) {
                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
                        HStack(spacing: 0) {
                            TimelineNode(isCompleted: timeline.completed)

                            if index < filteredTimeline.count - 1 {
                                TimelineConnector(isCompleted: filteredTimeline[index + 1].completed)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)

                // 상태 텍스트들
                HStack {
                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
                        TimelineLabel(timeline: timeline)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

//#Preview {
//    OrderTimelineSection()
//}
