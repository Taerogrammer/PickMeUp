//
//  StoreBottomBarView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreBottomBarView: View {
    let totalPrice: Int
    let itemCount: Int

    var body: some View {
        HStack {
            Text("\(totalPrice)원")
                .font(.headline)
            Spacer()
            Button(action: {
                // TODO: 결제 기능 연결
            }) {
                HStack {
                    Text("결제하기")
                    if itemCount > 0 {
                        Text("\(itemCount)")
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.shadow(radius: 4))
    }
}

//#Preview {
//    StoreBottomBarView()
//}
