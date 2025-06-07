//
//  StoreMenuListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuListView: View {
    let entity: StoreMenuListEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entity.menus, id: \.menuID) { menu in
                StoreMenuItemCardView(
                    menu: menu,
                    image: entity.loadedImages[menu.menuID]
                )
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    let mockEntity = StoreMenuListEntity(
//        menus: [
//            MenuItem(
//                name: "아메리카노",
//                description: "진하고 깔끔한 맛의 커피",
//                image: UIImage(systemName: "cup.and.saucer.fill")!,
//                isPopular: true,
//                rank: 1,
//                category: "커피",
//                price: 3000,
//                isSoldOut: false
//            ),
//            MenuItem(
//                name: "카페라떼",
//                description: "우유와 에스프레소의 부드러운 조화",
//                image: UIImage(systemName: "cup.and.saucer")!,
//                isPopular: false,
//                rank: 2,
//                category: "커피",
//                price: 3500,
//                isSoldOut: true
//            )
//        ]
//    )
//
//    return StoreMenuListView(entity: mockEntity)
//}
