//
//  SectionHeader.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct SectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.deepSprout)

            Text(title)
                .font(.pretendardCaption1)
                .fontWeight(.semibold)
                .foregroundColor(.gray90)
        }
    }
}
