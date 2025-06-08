//
//  StoreBottomBarView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreBottomBarView: View {
    let entity: StoreBottomBarEntity
    @ObservedObject var cartManager: CartManager

    var body: some View {
        HStack {
            Text("\(cartManager.totalPrice)원")
                .font(.pretendardTitle1)
            Spacer()
            Button(action: {
                // TODO: 결제 기능 연결
                print("🛒 결제하기: \(cartManager.itemCount)개 메뉴, 총 \(cartManager.totalPrice)원")
            }) {
                HStack {
                    if cartManager.itemCount > 0 {
                        Text("\(cartManager.itemCount)")
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
            .disabled(cartManager.itemCount == 0)
            .opacity(cartManager.itemCount == 0 ? 0.6 : 1.0)
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

//#Preview {
//    StoreBottomBarView(entity: .mock())
//}
