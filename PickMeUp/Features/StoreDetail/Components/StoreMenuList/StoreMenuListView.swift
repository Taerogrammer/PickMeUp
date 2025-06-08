//
//  StoreMenuListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuListView: View {
    let entity: StoreMenuListEntity
    @ObservedObject var cartManager: CartManager
    @State private var selectedMenu: StoreMenuItemEntity?
    @State private var showMenuDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entity.menus, id: \.menuID) { menu in
                StoreMenuItemCardView(
                    menu: menu,
                    image: entity.loadedImages[menu.menuID],
                    cartQuantity: cartManager.getQuantity(for: menu.menuID)
                )
                .onTapGesture {
                    selectedMenu = menu
                    showMenuDetail = true
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showMenuDetail) {
            if let selectedMenu = selectedMenu {
                MenuDetailSheetView(
                    menu: selectedMenu,
                    image: entity.loadedImages[selectedMenu.menuID],
                    cartManager: cartManager
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

//#Preview {
//    let mockEntity = StoreMenuListEntity(
//        menus: [
//            StoreMenuItemEntity(
//                menuID: "menu_001",
//                storeID: "store_123",
//                category: "커피",
//                name: "아메리카노",
//                description: "진하고 깔끔한 맛의 커피",
//                originInformation: "브라질산 원두 100%",
//                price: 3000,
//                isSoldOut: false,
//                menuImageURL: "https://example.com/americano.jpg"
//            ),
//            StoreMenuItemEntity(
//                menuID: "menu_002",
//                storeID: "store_123",
//                category: "커피",
//                name: "카페라떼",
//                description: "우유와 에스프레소의 부드러운 조화",
//                originInformation: "브라질산 원두, 국내산 우유",
//                price: 3500,
//                isSoldOut: true,
//                menuImageURL: "https://example.com/latte.jpg"
//            ),
//            StoreMenuItemEntity(
//                menuID: "menu_003",
//                storeID: "store_123",
//                category: "디저트",
//                name: "치즈케이크",
//                description: "부드럽고 달콤한 뉴욕 스타일 치즈케이크",
//                originInformation: "덴마크산 크림치즈",
//                price: 5500,
//                isSoldOut: false,
//                menuImageURL: "https://example.com/cheesecake.jpg"
//            )
//        ],
//        loadedImages: [
//            "menu_001": UIImage(systemName: "cup.and.saucer.fill") ?? UIImage(),
//            "menu_002": UIImage(systemName: "cup.and.saucer") ?? UIImage(),
//            "menu_003": UIImage(systemName: "birthday.cake") ?? UIImage()
//        ]
//    )
//
//    StoreMenuListView(entity: mockEntity)
//}
