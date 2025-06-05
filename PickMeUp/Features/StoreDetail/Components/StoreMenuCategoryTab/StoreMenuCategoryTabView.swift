//
//  StoreMenuCategoryTabView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuCategoryTabView: View {
    let entity: StoreMenuCategoryTabEntity
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(entity.categories, id: \.self) { category in
                    Button(action: {
                        onSelect(category)
                    }) {
                        Text(category)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(category == entity.selectedCategory ? Color.orange : Color.gray.opacity(0.2))
                            .foregroundColor(category == entity.selectedCategory ? .white : .black)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    StoreMenuCategoryTabView()
//}
