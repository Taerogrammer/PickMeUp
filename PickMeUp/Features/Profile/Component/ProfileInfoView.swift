//
//  ProfileInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI

struct ProfileInfoView: View {
    let displayName: String
    let email: String
    let phoneNumber: String

    var body: some View {
        VStack(spacing: 4) {
            Text(displayName)
                .font(.pretendardTitle1)
                .foregroundColor(.gray90)

            Text(email)
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)

            Text(phoneNumber)
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)
        }
    }
}

//#Preview {
//    ProfileInfoView()
//}
