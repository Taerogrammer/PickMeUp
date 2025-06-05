//
//  StoreNavigationButtonView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreNavigationButtonView: View {
    var body: some View {
        Button(action: {
            // TODO: 길찾기 기능 연결
        }) {
            Text("길찾기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}
#Preview {
    StoreNavigationButtonView()
}
