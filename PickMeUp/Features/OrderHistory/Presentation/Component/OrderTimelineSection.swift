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
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "clock.fill", title: "진행 상황")

            VStack(spacing: 8) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
                        VStack {
                            TimelineNode(isCompleted: timeline.completed)
                        }
                        .frame(maxWidth: .infinity)

                        if index < filteredTimeline.count - 1 {
                            TimelineConnector(isCompleted: filteredTimeline[index + 1].completed)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                HStack(spacing: 0) {
                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
                        TimelineLabel(timeline: timeline)
                            .frame(maxWidth: .infinity)

                        if index < filteredTimeline.count - 1 {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

//#Preview {
//    OrderTimelineSection()
//}
