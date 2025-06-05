//
//  StoreMenuCategoryTabView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuCategoryTabView: View {
    let selected: String
    let categories: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        onSelect(category)
                    }) {
                        Text(category)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(category == selected ? Color.orange : Color.gray.opacity(0.2))
                            .foregroundColor(category == selected ? .white : .black)
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
