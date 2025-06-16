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
            HStack(spacing: 4) {

                CategoryTabItem(
                    title: "전체",
                    isSelected: true,
                    icon: nil
                )

                CategoryTabItem(title: "인기메뉴", isSelected: false, icon: nil)
                CategoryTabItem(title: "수제도넛", isSelected: false, icon: nil)
                CategoryTabItem(title: "수제 젤라또", isSelected: false, icon: nil)
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryTabItem: View {
    let title: String
    let isSelected: Bool
    let icon: Image?

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
            }

            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(isSelected ? Color.deepSprout : Color.gray0)
        .foregroundColor(isSelected ? Color.gray0 : Color.gray60)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.deepSprout : Color.gray30, lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

#Preview {
    StoreMenuCategoryTabView(
        entity: StoreMenuCategoryTabEntity(
            selectedCategory: "커피",
            categories: ["전체", "커피", "디저트"]
        ),
        onSelect: { selected in
            print("선택된 카테고리: \(selected)")
        }
    )
    .padding()
}
