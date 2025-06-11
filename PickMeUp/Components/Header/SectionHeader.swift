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
        HStack {
            Image(systemName: icon)
                .foregroundColor(.deepSprout)
            Text(title)
                .font(.pretendardBody1)
                .fontWeight(.semibold)
                .foregroundColor(.gray90)
            Spacer()
        }
    }
}
