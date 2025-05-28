//
//  RoundedCorner.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
