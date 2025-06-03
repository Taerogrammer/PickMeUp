//
//  PickchelinConcaveRibbonView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct PickchelinConcaveRibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let arcRadius = rect.height / 2
        let tailWidth: CGFloat = arcRadius * 1.2

        var path = Path()

        // 시작점 (왼쪽 중앙)
        path.move(to: CGPoint(x: 0, y: rect.midY - arcRadius))

        // 왼쪽 concave arc (안쪽으로 파인 곡선)
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.midY + arcRadius),
            control: CGPoint(x: -arcRadius, y: rect.midY)
        )

        // 아래쪽 → 오른쪽
        path.addLine(to: CGPoint(x: rect.width - tailWidth, y: rect.height))

        // 오른쪽 꼬리 삼각형
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width - tailWidth, y: 0))

        // 위쪽 → 왼쪽
        path.addLine(to: CGPoint(x: 0, y: rect.midY - arcRadius))

        path.closeSubpath()
        return path
    }
}


struct PickchelinConcaveRibbonView: View {
    var body: some View {
        ZStack {
            PickchelinConcaveRibbonShape()
                .fill(Color.deepSprout)
                .overlay(
                    PickchelinConcaveRibbonShape()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )

            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text("픽슐랭")
                    .font(.pretendardBody2)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
        }
        .frame(height: 32)
        .fixedSize()
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
