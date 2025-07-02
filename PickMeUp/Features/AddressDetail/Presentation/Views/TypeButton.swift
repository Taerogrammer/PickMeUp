//
//  TypeButton.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

struct TypeButton: View {
    let type: LocationType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.deepSprout : Color.gray15)
                        .frame(width: 50, height: 50)

                    Image(systemName: type.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray60)
                }

                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color.deepSprout : .gray60)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
