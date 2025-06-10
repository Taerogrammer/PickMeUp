//
//  BeforeOrderListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct BeforeOrderListView: View {
    let orders: [OrderData]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if orders.isEmpty {
                    emptyStateView
                } else {
                    ForEach(Array(orders.enumerated()), id: \.element.orderID) { index, order in
                        PastOrderCard(orderData: order)
                            .id("past_\(index)")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray45)

            Text("과거 주문 내역이 없습니다")
                .font(.pretendardBody1)
                .foregroundColor(.gray60)

            Text("주문을 완료하면 여기에 표시됩니다")
                .font(.pretendardCaption1)
                .foregroundColor(.gray45)
        }
        .padding(.top, 100)
    }
}

struct PastOrderCard: View {
    let orderData: OrderData

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerSection

            // 메인 컨텐츠
            VStack(spacing: 20) {
                // 주문 정보
                orderInfoSection

                // 주문 메뉴 (요약)
                orderSummarySection

                // 하단 액션
                bottomActionSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // MARK: - 헤더
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("주문 완료")
                    .font(.pretendardBody2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(formatDate(orderData.createdAt))
                    .font(.pretendardCaption1)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // 완료 아이콘
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.gray60, Color.gray75]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    // MARK: - 주문 정보
    private var orderInfoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(orderData.store.name)
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)

                Text("주문번호 \(orderData.orderCode)")
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(orderData.totalPrice.formattedPrice)원")
                    .font(.pretendardBody1)
                    .fontWeight(.bold)
                    .foregroundColor(.gray90)

                Text("\(getTotalQuantity())개 상품")
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)
            }
        }
        .padding(16)
        .background(Color.gray15)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 주문 메뉴 요약
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(.gray60)
                Text("주문 내역")
                    .font(.pretendardCaption1)
                    .fontWeight(.medium)
                    .foregroundColor(.gray60)
                Spacer()
            }

            VStack(spacing: 8) {
                ForEach(Array(orderData.orderMenuList.prefix(2).enumerated()), id: \.offset) { index, orderMenu in
                    menuSummaryRow(orderMenu: orderMenu)
                }

                // 더 많은 메뉴가 있을 경우
                if orderData.orderMenuList.count > 2 {
                    HStack {
                        Text("외 \(orderData.orderMenuList.count - 2)개")
                            .font(.pretendardCaption1)
                            .foregroundColor(.gray45)
                        Spacer()
                    }
                }
            }
        }
    }

    private func menuSummaryRow(orderMenu: OrderMenu) -> some View {
        HStack(spacing: 12) {
            Text(orderMenu.menu.name)
                .font(.pretendardCaption1)
                .foregroundColor(.gray75)

            Spacer()

            Text("\(orderMenu.quantity)개")
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)

            Text("\(orderMenu.menu.price.formattedPrice)원")
                .font(.pretendardCaption1)
                .fontWeight(.medium)
                .foregroundColor(.gray75)
        }
    }

    // MARK: - 하단 액션
    private var bottomActionSection: some View {
        HStack(spacing: 12) {
            // 재주문 버튼
            Button(action: {
                // 재주문 액션
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                    Text("재주문")
                        .font(.pretendardCaption1)
                        .fontWeight(.medium)
                }
                .foregroundColor(.deepSprout)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.brightSprout.opacity(0.1))
                .clipShape(Capsule())
            }

            Spacer()

            // 리뷰 버튼
            if orderData.review != nil {
                reviewCompletedButton
            } else {
                writeReviewButton
            }
        }
    }

    private var writeReviewButton: some View {
        Button(action: {
            // 리뷰 작성 액션
        }) {
            HStack(spacing: 6) {
                Image(systemName: "star")
                    .font(.caption)
                Text("리뷰 작성")
                    .font(.pretendardCaption1)
                    .fontWeight(.medium)
            }
            .foregroundColor(.deepSprout)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.deepSprout.opacity(0.1))
            .clipShape(Capsule())
        }
    }

    private var reviewCompletedButton: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.deepSprout)
            Text("리뷰 완료")
                .font(.pretendardCaption1)
                .fontWeight(.medium)
                .foregroundColor(.gray60)

            if let review = orderData.review {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(star <= review.rating ? .deepSprout : .gray30)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray15)
        .clipShape(Capsule())
    }

    // MARK: - Helper Functions
    private func getTotalQuantity() -> Int {
        return orderData.orderMenuList.reduce(0) { $0 + $1.quantity }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "M월 d일"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    BeforeOrderListView(orders: [
        OrderData(
            orderID: "past_preview",
            orderCode: "B5831",
            totalPrice: 8500,
            review: Review(id: "review_1", rating: 4),
            store: Store(
                id: "store_2",
                category: "패스트푸드",
                name: "새싹 피자 창동점",
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
                        id: "menu3",
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
            orderStatusTimeline: [],
            paidAt: "",
            createdAt: "2024-01-20T15:08:00.000Z",
            updatedAt: ""
        )
    ])
    .padding()
    .background(Color.gray15)
}

//#Preview {
//    BeforeOrderListView()
//}
