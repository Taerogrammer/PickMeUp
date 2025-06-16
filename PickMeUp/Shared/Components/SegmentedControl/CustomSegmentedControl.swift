//
//  CustomSegmentedControl.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var preselectedIndex: Int
    var options: [String]

    // 브랜드 컬러 사용
    let primaryColor = Color.deepSprout
    let backgroundColor = Color.gray15

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                ZStack {
                    // 배경
                    Rectangle()
                        .fill(backgroundColor)

                    // 선택된 항목 배경
                    Rectangle()
                        .fill(primaryColor)
                        .cornerRadius(16)
                        .padding(3)
                        .opacity(preselectedIndex == index ? 1 : 0.01)
                        .shadow(
                            color: preselectedIndex == index ? primaryColor.opacity(0.3) : Color.clear,
                            radius: preselectedIndex == index ? 4 : 0,
                            x: 0,
                            y: 2
                        )
                }
                .overlay(
                    // 텍스트
                    Text(options[index])
                        .font(.pretendardBody2)
                        .fontWeight(.semibold)
                        .foregroundColor(preselectedIndex == index ? .white : .gray60)
                        .animation(.easeInOut(duration: 0.2), value: preselectedIndex)
                )
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                        preselectedIndex = index
                    }
                }
            }
        }
        .frame(height: 48)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

//#Preview {
//    CustomSegmentedControl()
//}
