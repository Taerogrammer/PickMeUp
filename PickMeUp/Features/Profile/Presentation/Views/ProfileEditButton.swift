//
//  ProfileEditButton.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI

struct ProfileEditButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("프로필 수정")
                    .foregroundColor(.gray90)
                    .font(.pretendardBody2)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray60)
            }
            .padding()
            .background(Color.gray15)
            .cornerRadius(10)
        }
    }
}
