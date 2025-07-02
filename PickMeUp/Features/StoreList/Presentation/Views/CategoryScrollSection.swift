//
//  CategorySectionScroll.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import SwiftUI

// 카테고리 스크롤 섹션 분리
struct CategoryScrollSection: View, Equatable {
    let categories: [CategoryButtonData]
    let selectedCategory: String
    let onCategorySelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    CategoryButton(
                        imageName: category.imageName,
                        title: category.title,
                        isSelected: selectedCategory == category.title
                    ) {
                        onCategorySelect(category.title)
                    }
                }
            }
            .padding([.top, .leading, .trailing])
        }
    }

    static func == (lhs: CategoryScrollSection, rhs: CategoryScrollSection) -> Bool {
        lhs.selectedCategory == rhs.selectedCategory &&
        lhs.categories == rhs.categories
    }
}
