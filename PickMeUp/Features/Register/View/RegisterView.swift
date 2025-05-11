//
//  RegisterView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("회원가입")
                .font(.title)

            TextField("사용자 이름", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("완료") {
                print("회원가입 완료: \(username)")
            }
        }
        .padding()
    }
}
#Preview {
    RegisterView()
}
