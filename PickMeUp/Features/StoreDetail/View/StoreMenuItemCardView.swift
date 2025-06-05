//
//  StoreMenuItemCardView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuItemCardView: View {
    let menu: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 메뉴 이미지
            Image(uiImage: menu.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(8)

            // 메뉴 정보
            VStack(alignment: .leading, spacing: 6) {
                if menu.isPopular {
                    Text("인기 \(menu.rank)위")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .bold()
                }

                Text(menu.name)
                    .font(.headline)

                Text(menu.description)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(menu.price.formatted())원")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }

            Spacer()

            if menu.isSoldOut {
                Text("품절")
                    .font(.caption)
                    .padding(6)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }
}

//#Preview {
//    StoreMenuItemCardView()
//}
