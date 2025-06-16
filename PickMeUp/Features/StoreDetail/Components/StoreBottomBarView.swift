//
//  StoreBottomBarView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreBottomBarView: View {
    let entity: StoreBottomBarEntity
    @ObservedObject var store: StoreDetailStore

    var body: some View {
        HStack {
            Text("\(store.state.cartTotalPrice)원")
                .font(.pretendardTitle1)
            Spacer()
            Button(action: {
                store.send(.tapPay)
            }) {
                HStack {
                    if store.state.isOrderLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        if store.state.cartItemCount > 0 {
                            Text("\(store.state.cartItemCount)")
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .foregroundColor(.deepSprout)
                        }
                        Text("결제하기")
                            .font(.pretendardTitle1)
                    }
                }
                .padding()
                .background(Color.deepSprout)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(store.state.cartItemCount == 0 || store.state.isOrderLoading)
            .opacity(store.state.cartItemCount == 0 || store.state.isOrderLoading ? 0.6 : 1.0)
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
