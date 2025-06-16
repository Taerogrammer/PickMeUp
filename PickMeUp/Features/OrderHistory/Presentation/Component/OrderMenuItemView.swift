//
//  OrderMenuItemView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderMenuItemView: View {
    let store: OrderHistoryStore
    let menuItem: OrderMenuEntity
    let orderCode: String

    var body: some View {
        HStack(spacing: 16) {
            menuImageView

            VStack(alignment: .leading, spacing: 6) {
                Text(menuItem.menu.name)
                    .font(.pretendardBody1)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray90)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text("\(menuItem.menu.price.formattedPrice)원")
                        .font(.pretendardBody2)
                        .fontWeight(.medium)
                        .foregroundColor(.deepSprout)

                    Text("×")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray45)

                    Text("\(menuItem.quantity)")
                        .font(.pretendardBody2)
                        .fontWeight(.semibold)
                        .foregroundColor(.deepSprout)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brightSprout.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray15, lineWidth: 1)
        )
        .onAppear {
           let imageUrl = menuItem.menu.menuImageUrl
           if !imageUrl.isEmpty {
               store.send(.loadMenuImage(
                   orderCode: orderCode,
                   menuID: menuItem.menu.id,
                   imageUrl: imageUrl
               ))
           }
        }
    }

    @ViewBuilder
    private var menuImageView: some View {
        if let image = store.state.getMenuImage(orderCode: orderCode, menuID: menuItem.menu.id) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray15, Color.gray15]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.gray45)
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

//#Preview {
//    OrderMenuItemView()
//}
