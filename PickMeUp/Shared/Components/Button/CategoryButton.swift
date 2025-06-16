//
//  CategoryButton.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

struct CategoryButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.deepSprout : Color.gray30, lineWidth: 2)
                        .frame(width: 56, height: 56)

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
            }

            Text(title)
                .font(.pretendardCaption1)
                .foregroundColor(isSelected ? .deepSprout : .gray60)
        }
    }
}
