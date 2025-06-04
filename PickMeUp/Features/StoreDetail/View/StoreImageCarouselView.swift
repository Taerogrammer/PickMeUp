//
//  StoreImageCarouselView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreImageCarouselView: View {
    let images: [UIImage]
    let onBack: () -> Void
    let onLike: () -> Void
    let isLiked: Bool

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipped()
                }
            }
            .frame(height: 240)
            .tabViewStyle(PageTabViewStyle())

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray0)
                }


                Spacer()

                Button(action: onLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isLiked ? .deepSprout : .gray0)
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    let mockImages: [UIImage] = Array(repeating: makeGrayImage(size: CGSize(width: 400, height: 240)), count: 3)

    StoreImageCarouselView(
        images: mockImages,
        onBack: { print("back") },
        onLike: { print("like") },
        isLiked: true
    )
}

fileprivate func makeGrayImage(size: CGSize = CGSize(width: 100, height: 100), color: UIColor = .systemGray5) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
