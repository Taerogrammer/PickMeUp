//
//  StoreMenuItemCardView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuItemCardView: View {
    let menu: StoreMenuItemEntity
    let image: UIImage?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ZStack {
                    Color.gray30
                    ProgressView()
                }
                .frame(width: 72, height: 72)
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 6) {
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
