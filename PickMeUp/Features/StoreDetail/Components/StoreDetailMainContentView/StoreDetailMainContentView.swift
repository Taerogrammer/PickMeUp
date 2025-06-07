//
//  StoreDetailMainContentView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/6/25.
//

import SwiftUI

struct StoreDetailMainContentView: View {
    let summaryEntity: StoreSummaryInfoEntity
    let detailEntity: StoreDetailInfoEntity
    let estimatedTimeEntity: StoreEstimatedTimeEntity
    let categoryTabEntity: StoreMenuCategoryTabEntity
    let menuListEntity: StoreMenuListEntity
    let onSelectCategory: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            StoreSummaryInfoView(entity: summaryEntity)
            StoreDetailInfoView(entity: detailEntity)
            StoreEstimatedTimeView(entity: estimatedTimeEntity)
            StoreNavigationButtonView()
            Divider()
            StoreMenuCategoryTabView(entity: categoryTabEntity, onSelect: onSelectCategory)
            StoreMenuListView(entity: menuListEntity)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
    }
}

//#Preview {
//    StoreDetailMainContentView(
//        summaryEntity: StoreSummaryInfoEntity(
//            name: "해피도넛",
//            isPickchelin: true,
//            pickCount: 128,
//            totalRating: 4.8,
//            totalReviewCount: 52,
//            totalOrderCount: 430
//        ),
//        detailEntity: StoreDetailInfoEntity(
//            address: "서울시 강남구 도산대로 123",
//            open: "10:00",
//            close: "22:00",
//            parkingGuide: "건물 지하 주차장 이용 가능"
//        ),
//        estimatedTimeEntity: StoreEstimatedTimeEntity(
//            estimatedPickupTime: 30,
//            distance: "1.2km"
//        ),
//        categoryTabEntity: StoreMenuCategoryTabEntity(
//            selectedCategory: "전체", categories: ["전체", "수제도넛", "음료"]
//        ),
//        menuListEntity: StoreMenuListEntity(
//            menus: [
//                MenuItem(
//                    name: "올리브 그린 새싹 도넛",
//                    description: "겉은 바삭하고 속은 촉촉한 허브향 도넛",
//                    image: UIImage(systemName: "photo")!,
//                    isPopular: true,
//                    rank: 1,
//                    category: "수제도넛",
//                    price: 2100,
//                    isSoldOut: false
//                ),
//                MenuItem(
//                    name: "초코 폭탄 도넛",
//                    description: "진한 초코가 가득한 인기 메뉴",
//                    image: UIImage(systemName: "photo")!,
//                    isPopular: false,
//                    rank: 2,
//                    category: "수제도넛",
//                    price: 1900,
//                    isSoldOut: true
//                )
//            ]
//        ),
//        onSelectCategory: { _ in }
//    )
//}
