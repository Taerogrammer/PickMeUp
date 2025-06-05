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
            ForEach(entity.menus, id: \.self) { menu in
                StoreMenuItemCardView(menu: menu)
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    StoreMenuListView()
//}
