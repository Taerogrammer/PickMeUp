//
//  OrderInfoRow.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.deepSprout)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)
                Text(value)
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
            }

            Spacer()
        }
    }
}
