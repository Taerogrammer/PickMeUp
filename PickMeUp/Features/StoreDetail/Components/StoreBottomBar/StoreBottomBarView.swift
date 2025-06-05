//
//  StoreBottomBarView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreBottomBarView: View {
    let entity: StoreBottomBarEntity

    var body: some View {
        HStack {
            Text("\(entity.totalPrice)원")
                .font(.pretendardTitle1)
            Spacer()
            Button(action: {
                // TODO: 결제 기능 연결
            }) {
                HStack {
                    if entity.itemCount > 0 {
                        Text("\(entity.itemCount)")
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(.deepSprout)
                    }
                    Text("결제하기")
                        .font(.pretendardTitle1)
                }
                .padding()
                .background(Color.deepSprout)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }
}

#Preview {
    StoreBottomBarView(entity: .mock())
}
