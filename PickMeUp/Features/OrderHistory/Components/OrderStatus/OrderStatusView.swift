//
//  OrderStatusView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderStatusView: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore

    var body: some View {
        if orderData.orderStatus == "PICKED_UP" {
            EmptyView()
        } else {
            OrderStatusCard(orderData: orderData, store: store)
        }
    }
}

// MARK: - OrderStatusCard
struct OrderStatusCard: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore

    var body: some View {
        VStack(spacing: 0) {
            OrderStatusHeader(orderData: orderData)

            VStack(spacing: 28) {
                OrderInfoSection(orderData: orderData)
                OrderTimelineSection(orderData: orderData)

                if shouldShowStatusButton {
                    OrderStatusActionSection(orderData: orderData, store: store)
                }

                OrderMenuSection(orderData: orderData)
                OrderPaymentSection(orderData: orderData)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var shouldShowStatusButton: Bool {
        ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(orderData.orderStatus)
    }
}

//// MARK: - Header Section
//struct OrderStatusHeader: View {
//    let orderData: OrderDataEntity
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("주문현황")
//                    .font(.pretendardTitle1)
//                    .foregroundColor(.white)
//                    .fontWeight(.bold)
//
//                Text("Order Status")
//                    .font(.pretendardCaption1)
//                    .foregroundColor(.white.opacity(0.8))
//            }
//
//            Spacer()
//
//            OrderStatusBadge(status: orderData.orderStatus)
//        }
//        .padding(.horizontal, 24)
//        .padding(.vertical, 20)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [Color.deepSprout, Color.brightSprout]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//        )
//    }
//}

//struct OrderStatusBadge: View {
//    let status: String
//
//    var body: some View {
//        Text(getStatusDisplayName(status))
//            .font(.pretendardCaption1)
//            .fontWeight(.semibold)
//            .foregroundColor(.deepSprout)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(Color.white)
//            .clipShape(Capsule())
//            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//    }
//}

// MARK: - Order Info Section
//struct OrderInfoSection: View {
//    let orderData: OrderDataEntity
//
//    var body: some View {
//        VStack(spacing: 12) {
//            OrderInfoRow(
//                icon: "number.circle.fill",
//                title: "주문번호",
//                value: orderData.orderCode
//            )
//
//            Divider().background(Color.gray15)
//
//            HStack {
//                OrderInfoRow(
//                    icon: "storefront.fill",
//                    title: "매장명",
//                    value: orderData.store.name
//                )
//
//                Spacer()
//
//                VStack(alignment: .trailing, spacing: 2) {
//                    Text("주문시간")
//                        .font(.pretendardCaption1)
//                        .foregroundColor(.gray60)
//                    Text(formatDate(orderData.createdAt))
//                        .font(.pretendardCaption1)
//                        .foregroundColor(.gray60)
//                }
//            }
//        }
//        .padding(20)
//        .background(Color.gray15)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//}

//struct OrderInfoRow: View {
//    let icon: String
//    let title: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(.deepSprout)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.pretendardCaption1)
//                    .foregroundColor(.gray60)
//                Text(value)
//                    .font(.pretendardBody1)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.gray90)
//            }
//
//            Spacer()
//        }
//    }
//}

// MARK: - Timeline Section
//struct OrderTimelineSection: View {
//    let orderData: OrderDataEntity
//
//    private var filteredTimeline: [OrderStatusTimelineEntity] {
//        orderData.orderStatusTimeline.filter { $0.status != "PICKED_UP" }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            SectionHeader(icon: "clock.fill", title: "진행 상황")
//
//            VStack(spacing: 16) {
//                // 타임라인 점들과 연결선
//                HStack(spacing: 0) {
//                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
//                        HStack(spacing: 0) {
//                            TimelineNode(isCompleted: timeline.completed)
//
//                            if index < filteredTimeline.count - 1 {
//                                TimelineConnector(isCompleted: filteredTimeline[index + 1].completed)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal, 10)
//
//                // 상태 텍스트들
//                HStack {
//                    ForEach(Array(filteredTimeline.enumerated()), id: \.offset) { index, timeline in
//                        TimelineLabel(timeline: timeline)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//            }
//            .padding(.vertical, 8)
//        }
//    }
//}

//struct TimelineNode: View {
//    let isCompleted: Bool
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(isCompleted ? Color.deepSprout : Color.gray15)
//                .frame(width: 20, height: 20)
//
//            if isCompleted {
//                Image(systemName: "checkmark")
//                    .font(.system(size: 10, weight: .bold))
//                    .foregroundColor(.white)
//            }
//        }
//        .shadow(color: isCompleted ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
//    }
//}
//
//struct TimelineConnector: View {
//    let isCompleted: Bool
//
//    var body: some View {
//        Rectangle()
//            .fill(isCompleted ? Color.deepSprout : Color.gray15)
//            .frame(height: 2)
//            .frame(maxWidth: .infinity)
//    }
//}

//struct TimelineLabel: View {
//    let timeline: OrderStatusTimelineEntity
//
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(getStatusDisplayName(timeline.status))
//                .font(.pretendardCaption1)
//                .fontWeight(timeline.completed ? .semibold : .regular)
//                .foregroundColor(timeline.completed ? .gray90 : .gray45)
//                .multilineTextAlignment(.center)
//
//            if let changedAt = timeline.changedAt, timeline.completed {
//                Text(formatTime(changedAt))
//                    .font(.pretendardCaption2)
//                    .foregroundColor(.deepSprout)
//                    .fontWeight(.medium)
//            }
//        }
//    }
//}

// MARK: - Status Action Section
//struct OrderStatusActionSection: View {
//    let orderData: OrderDataEntity
//    @ObservedObject var store: OrderHistoryStore
//
//    var body: some View {
//        VStack(spacing: 16) {
//            SectionHeader(icon: "arrow.clockwise.circle.fill", title: "주문 진행")
//
//            Button(action: {
//                store.send(.updateOrderStatus(
//                    orderCode: orderData.orderCode,
//                    currentStatus: orderData.orderStatus
//                ))
//            }) {
//                HStack(spacing: 12) {
//                    Image(systemName: getButtonIcon(orderData.orderStatus))
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(isPickupReady ? .white : .gray15)
//
//                    Text(getButtonText(orderData.orderStatus))
//                        .font(.pretendardBody1)
//                        .fontWeight(.semibold)
//                        .foregroundColor(isPickupReady ? .white : .gray15)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background(buttonBackground)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .shadow(color: isPickupReady ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
//            }
//        }
//        .padding(20)
//        .background(Color.gray15)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//
//    private var isPickupReady: Bool {
//        orderData.orderStatus == "READY_FOR_PICKUP"
//    }
//
//    private var buttonBackground: LinearGradient {
//        LinearGradient(
//            gradient: Gradient(colors: isPickupReady ? [Color.deepSprout, Color.brightSprout] : [Color.gray60, Color.gray60]),
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//    }
//}

// MARK: - Menu Section
//struct OrderMenuSection: View {
//    let orderData: OrderDataEntity
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            SectionHeader(icon: "menucard.fill", title: "주문 메뉴")
//
//            VStack(spacing: 12) {
//                ForEach(Array(orderData.orderMenuList.enumerated()), id: \.offset) { index, menuItem in
//                    OrderMenuItemView(menuItem: menuItem)
//                }
//            }
//        }
//    }
//}

//struct OrderMenuItemView: View {
//    let menuItem: OrderMenuEntity
//
//    var body: some View {
//        HStack(spacing: 16) {
//            // 메뉴 이미지 (플레이스홀더만 사용)
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color.gray15, Color.gray15]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ))
//
//                Image(systemName: "photo")
//                    .font(.title2)
//                    .foregroundColor(.gray45)
//            }
//            .frame(width: 70, height: 70)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//
//            // 메뉴 정보 - OrderMenuEntity의 실제 프로퍼티 사용
//            VStack(alignment: .leading, spacing: 6) {
//                Text(menuItem.menu.name)
//                    .font(.pretendardBody1)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.gray90)
//                    .lineLimit(2)
//
//                HStack(spacing: 8) {
//                    Text("\(menuItem.menu.price.formattedPrice)원")
//                        .font(.pretendardBody2)
//                        .fontWeight(.medium)
//                        .foregroundColor(.deepSprout)
//
//                    Text("×")
//                        .font(.pretendardCaption1)
//                        .foregroundColor(.gray45)
//
//                    Text("\(menuItem.quantity)")
//                        .font(.pretendardBody2)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.deepSprout)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 2)
//                        .background(Color.brightSprout.opacity(0.2))
//                        .clipShape(Capsule())
//                }
//            }
//
//            Spacer()
//        }
//        .padding(16)
//        .background(Color.white)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.gray15, lineWidth: 1)
//        )
//    }
//}

// MARK: - Payment Section
//struct OrderPaymentSection: View {
//    let orderData: OrderDataEntity
//
//    var body: some View {
//        VStack(spacing: 12) {
//            SectionHeader(icon: "creditcard.fill", title: "결제 정보")
//
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("총 \(getTotalQuantity(orderData))개 상품")
//                        .font(.pretendardBody2)
//                        .foregroundColor(.gray60)
//                    Text("결제완료")
//                        .font(.pretendardCaption1)
//                        .foregroundColor(.deepSprout)
//                        .fontWeight(.medium)
//                }
//
//                Spacer()
//
//                Text("\(orderData.totalPrice.formattedPrice)원")
//                    .font(.pretendardTitle1)
//                    .fontWeight(.bold)
//                    .foregroundColor(.gray90)
//            }
//            .padding(20)
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.brightSprout.opacity(0.1), Color.deepSprout.opacity(0.05)]),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//        }
//    }
//}

// MARK: - Common Components
//struct SectionHeader: View {
//    let icon: String
//    let title: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(.deepSprout)
//            Text(title)
//                .font(.pretendardBody1)
//                .fontWeight(.semibold)
//                .foregroundColor(.gray90)
//            Spacer()
//        }
//    }
//}

// MARK: - Helper Functions
private func getStatusDisplayName(_ status: String) -> String {
    switch status {
    case "PENDING_APPROVAL": return "승인대기"
    case "APPROVED": return "주문승인"
    case "IN_PROGRESS": return "조리 중"
    case "READY_FOR_PICKUP": return "픽업대기"
    case "PICKED_UP": return "픽업완료"
    default: return status
    }
}

private func getButtonText(_ status: String) -> String {
    switch status {
    case "PENDING_APPROVAL": return "주문 승인"
    case "APPROVED": return "조리 시작하기"
    case "IN_PROGRESS": return "픽업대기"
    case "READY_FOR_PICKUP": return "픽업 하기"
    default: return "다음 단계로"
    }
}

private func getButtonIcon(_ status: String) -> String {
    switch status {
    case "PENDING_APPROVAL": return "checkmark.circle.fill"
    case "APPROVED": return "flame.fill"
    case "IN_PROGRESS": return "checkmark.shield.fill"
    case "READY_FOR_PICKUP": return "hand.raised.fill"
    default: return "arrow.right.circle.fill"
    }
}

private func formatDate(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    if let date = formatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "M/d HH:mm"
        return displayFormatter.string(from: date)
    }
    return dateString
}

private func formatTime(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    if let date = formatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }
    return dateString
}

private func getTotalQuantity(_ orderData: OrderDataEntity) -> Int {
    return orderData.orderMenuList.reduce(0) { $0 + $1.quantity }
}





// MARK: - Extensions
//extension Int {
//    var formattedPrice: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
//    }
//}

// MARK: - Preview
struct OrderStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                OrderStatusView(orderData: sampleOrderData,
                                store: OrderHistoryStore())
                OrderStatusView(orderData: sampleOrderData2,
                                store: OrderHistoryStore())
                OrderStatusView(orderData: sampleOrderData3,
                                store: OrderHistoryStore())
            }
            .padding()
        }
        .background(Color.gray15)
    }

    static let sampleOrderData = OrderDataEntity(
        orderID: "sample_id",
        orderCode: "A4922",
        totalPrice: 17200,
        review: nil,
        store: StoreEntity(
            id: "store_id",
            category: "카페",
            name: "새싹 도넛 가게",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu1",
                    name: "올리브 그린 새싹 도넛",
                    price: 1600,
                    menuImageUrl: ""
                ),
                quantity: 2
            )
        ],
        orderStatus: "READY_FOR_PICKUP",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: true, changedAt: nil),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: false, changedAt: nil)
        ],
        paidAt: "",
        createdAt: "2024-01-22T17:20:00.000Z",
        updatedAt: ""
    )

    static let sampleOrderData2 = OrderDataEntity(
        orderID: "sample_id_2",
        orderCode: "B5831",
        totalPrice: 8500,
        review: nil,
        store: StoreEntity(
            id: "store_id_2",
            category: "피자",
            name: "새싹 피자 홍대점",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu2",
                    name: "새싹 특제 피자",
                    price: 8500,
                    menuImageUrl: ""
                ),
                quantity: 1
            )
        ],
        orderStatus: "PICKED_UP",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-21T15:10:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-21T15:12:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-21T15:25:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-21T15:40:00.000Z"),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: true, changedAt: "2024-01-21T15:45:00.000Z")
        ],
        paidAt: "",
        createdAt: "2024-01-21T15:08:00.000Z",
        updatedAt: ""
    )

    static let sampleOrderData3 = OrderDataEntity(
        orderID: "sample_id",
        orderCode: "A4922",
        totalPrice: 17200,
        review: nil,
        store: StoreEntity(
            id: "store_id",
            category: "카페",
            name: "새싹 도넛 가게",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu1",
                    name: "올리브 그린 새싹 도넛",
                    price: 1600,
                    menuImageUrl: ""
                ),
                quantity: 2
            )
        ],
        orderStatus: "IN_PROGRESS",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: false, changedAt: nil),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: false, changedAt: nil)
        ],
        paidAt: "",
        createdAt: "2024-01-22T17:20:00.000Z",
        updatedAt: ""
    )
}
