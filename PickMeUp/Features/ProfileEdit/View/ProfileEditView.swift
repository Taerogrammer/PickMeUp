//
//  ProfileEditView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

struct ProfileEditView: View {
    var body: some View {
        VStack {
            Text("프로필 수정 페이지")
                .font(.title)
                .padding()

            Spacer()
        }
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}

#Preview {
    ProfileEditView()
}
