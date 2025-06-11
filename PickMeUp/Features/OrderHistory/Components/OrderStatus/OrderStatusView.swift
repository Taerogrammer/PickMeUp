//
//  OrderStatusView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderStatusView: View {
    let orderData: OrderData

    var body: some View {
        VStack(spacing: 0) {
            // 그라데이션 헤더
            headerSection
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.deepSprout, Color.brightSprout]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // 메인 컨텐츠
            VStack(spacing: 28) {
                // 주문 정보 섹션
                orderInfoSection

                // 주문 상태 타임라인
                orderTimelineSection

                // 주문 메뉴 리스트
                orderMenuSection

                // 결제 금액
                paymentSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - 헤더 섹션
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("주문현황")
                    .font(.pretendardTitle1)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text("Order Status")
                    .font(.pretendardCaption1)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // 상태 뱃지
            statusBadge
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var statusBadge: some View {
        Text(getStatusDisplayName(orderData.currentOrderStatus))
            .font(.pretendardCaption1)
            .fontWeight(.semibold)
            .foregroundColor(.deepSprout)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - 주문 정보 섹션
    private var orderInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "number.circle.fill")
                    .font(.title2)
                    .foregroundColor(.deepSprout)

                VStack(alignment: .leading, spacing: 2) {
                    Text("주문번호")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Text(orderData.orderCode)
                        .font(.pretendardBody1)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray90)
                }

                Spacer()
            }

            Divider()
                .background(Color.gray15)

            HStack {
                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundColor(.deepSprout)

                VStack(alignment: .leading, spacing: 2) {
                    Text("매장명")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Text(orderData.store.name)
                        .font(.pretendardBody1)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray90)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("주문시간")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Text(formatDate(orderData.createdAt))
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                }
            }
        }
        .padding(20)
        .background(Color.gray15)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 주문 상태 타임라인
    private var orderTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.deepSprout)
                Text("진행 상황")
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
                Spacer()
            }

            // 가로 타임라인
            horizontalTimelineView
        }
    }

    private var horizontalTimelineView: some View {
        VStack(spacing: 16) {
            // 타임라인 점들과 연결선
            HStack(spacing: 0) {
                ForEach(Array(orderData.orderStatusTimeline.enumerated()), id: \.offset) { index, timeline in
                    HStack(spacing: 0) {
                        // 타임라인 점
                        ZStack {
                            Circle()
                                .fill(timeline.completed ? Color.deepSprout : Color.gray15)
                                .frame(width: 20, height: 20)

                            if timeline.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: timeline.completed ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)

                        // 연결선 (마지막 항목이 아닌 경우)
                        if index < orderData.orderStatusTimeline.count - 1 {
                            Rectangle()
                                .fill(orderData.orderStatusTimeline[index + 1].completed ? Color.deepSprout : Color.gray15)
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)

            // 상태 텍스트들
            HStack {
                ForEach(Array(orderData.orderStatusTimeline.enumerated()), id: \.offset) { index, timeline in
                    VStack(spacing: 4) {
                        Text(getStatusDisplayName(timeline.status))
                            .font(.pretendardCaption1)
                            .fontWeight(timeline.completed ? .semibold : .regular)
                            .foregroundColor(timeline.completed ? .gray90 : .gray45)
                            .multilineTextAlignment(.center)

                        if let changedAt = timeline.changedAt, timeline.completed {
                            Text(formatTime(changedAt))
                                .font(.pretendardCaption2)
                                .foregroundColor(.deepSprout)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func timelineItem(timeline: OrderStatusTimeline, isLast: Bool) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // 상태 아이콘 (개선된 디자인)
            ZStack {
                Circle()
                    .fill(timeline.completed ? Color.deepSprout : Color.gray15)
                    .frame(width: 24, height: 24)

                if timeline.completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                }
            }
            .shadow(color: timeline.completed ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)

            // 상태 텍스트와 시간
            VStack(alignment: .leading, spacing: 2) {
                Text(getStatusDisplayName(timeline.status))
                    .font(.pretendardBody2)
                    .fontWeight(timeline.completed ? .semibold : .regular)
                    .foregroundColor(timeline.completed ? .gray90 : .gray45)

                if let changedAt = timeline.changedAt, timeline.completed {
                    Text(formatTime(changedAt))
                        .font(.pretendardCaption2)
                        .foregroundColor(.deepSprout)
                        .fontWeight(.medium)
                }
            }

            Spacer()
        }
        .overlay(
            // 연결선 (개선된 스타일)
            !isLast ? Rectangle()
                .fill(Color.gray15)
                .frame(width: 2)
                .offset(x: 11, y: 20)
            : nil
        )
    }

    // MARK: - 주문 메뉴 섹션
    private var orderMenuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "menucard.fill")
                    .foregroundColor(.deepSprout)
                Text("주문 메뉴")
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(Array(orderData.orderMenuList.enumerated()), id: \.offset) { index, orderMenu in
                    menuItem(orderMenu: orderMenu)
                }
            }
        }
    }

    private func menuItem(orderMenu: OrderMenu) -> some View {
        HStack(spacing: 16) {
            // 메뉴 이미지 (개선된 플레이스홀더)
            AsyncImage(url: URL(string: "https://your-base-url.com\(orderMenu.menu.menuImageUrl)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray15, Color.gray15]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.gray45)
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // 메뉴 정보
            VStack(alignment: .leading, spacing: 6) {
                Text(orderMenu.menu.name)
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text("\(orderMenu.menu.price.formattedPrice)원")
                        .font(.pretendardBody2)
                        .fontWeight(.medium)
                        .foregroundColor(.deepSprout)

                    Text("×")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray45)

                    Text("\(orderMenu.quantity)")
                        .font(.pretendardBody2)
                        .fontWeight(.semibold)
                        .foregroundColor(.deepSprout)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brightSprout.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray15, lineWidth: 1)
        )
    }

    // MARK: - 결제 금액 섹션
    private var paymentSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.deepSprout)
                Text("결제 정보")
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("총 \(getTotalQuantity())개 상품")
                        .font(.pretendardBody2)
                        .foregroundColor(.gray60)
                    Text("결제완료")
                        .font(.pretendardCaption1)
                        .foregroundColor(.deepSprout)
                        .fontWeight(.medium)
                }

                Spacer()

                Text("\(orderData.totalPrice.formattedPrice)원")
                    .font(.pretendardTitle1)
                    .fontWeight(.bold)
                    .foregroundColor(.gray90)
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.brightSprout.opacity(0.1), Color.deepSprout.opacity(0.05)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Helper Functions
    private func getStatusDisplayName(_ status: String) -> String {
        switch status {
        case "PENDING_APPROVAL":
            return "승인대기"
        case "APPROVED":
            return "주문승인"
        case "IN_PROGRESS":
            return "조리 중"
        case "READY_FOR_PICKUP":
            return "픽업대기"
        case "PICKED_UP":
            return "픽업완료"
        default:
            return status
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

    private func getTotalQuantity() -> Int {
        return orderData.orderMenuList.reduce(0) { $0 + $1.quantity }
    }
}

// MARK: - Extensions
extension Int {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Preview
struct OrderStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                OrderStatusView(orderData: sampleOrderData)
                OrderStatusView(orderData: sampleOrderData2)
            }
            .padding()
        }
        .background(Color.gray15)
    }

    static let sampleOrderData = OrderData(
        orderID: "sample_id",
        orderCode: "A4922",
        totalPrice: 17200,
        review: nil,
        store: Store(
            id: "store_id",
            category: "카페",
            name: "새싹 도넛 가게",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: Geolocation(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenu(
                menu: MenuInfo(
                    id: "menu1",
                    category: "도넛",
                    name: "올리브 그린 새싹 도넛",
                    description: "",
                    originInformation: "",
                    price: 1600,
                    tags: [],
                    menuImageUrl: "",
                    createdAt: "",
                    updatedAt: ""
                ),
                quantity: 2
            )
        ],
        currentOrderStatus: "IN_PROGRESS",
        orderStatusTimeline: [
            OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
            OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
            OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
            OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: false, changedAt: nil),
            OrderStatusTimeline(status: "PICKED_UP", completed: false, changedAt: nil)
        ],
        paidAt: "",
        createdAt: "2024-01-22T17:20:00.000Z",
        updatedAt: ""
    )

    static let sampleOrderData2 = OrderData(
        orderID: "sample_id_2",
        orderCode: "B5831",
        totalPrice: 8500,
        review: nil,
        store: Store(
            id: "store_id_2",
            category: "피자",
            name: "새싹 피자 홍대점",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: Geolocation(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenu(
                menu: MenuInfo(
                    id: "menu2",
                    category: "피자",
                    name: "새싹 특제 피자",
                    description: "",
                    originInformation: "",
                    price: 8500,
                    tags: [],
                    menuImageUrl: "",
                    createdAt: "",
                    updatedAt: ""
                ),
                quantity: 1
            )
        ],
        currentOrderStatus: "PICKED_UP",
        orderStatusTimeline: [
            OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-21T15:10:00.000Z"),
            OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-21T15:12:00.000Z"),
            OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-21T15:25:00.000Z"),
            OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-21T15:40:00.000Z"),
            OrderStatusTimeline(status: "PICKED_UP", completed: true, changedAt: "2024-01-21T15:45:00.000Z")
        ],
        paidAt: "",
        createdAt: "2024-01-21T15:08:00.000Z",
        updatedAt: ""
    )
}
