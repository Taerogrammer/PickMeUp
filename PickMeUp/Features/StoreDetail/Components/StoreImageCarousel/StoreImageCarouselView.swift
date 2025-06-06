//
//  StoreImageCarouselView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreImageCarouselView: View {
    let entity: StoreImageCarouselEntity
    let onBack: () -> Void
    let onLike: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                ForEach(entity.imageURLs.indices, id: \.self) { index in
                    let imageURL = entity.imageURLs[index]

                    if let loadedImage = entity.loadedImages[imageURL] {
                        Image(uiImage: loadedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .clipped()
                    } else {
                        // 로딩 중 상태 표시
                        ProgressView()
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
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
                        .padding(6)
                }
                .frame(width: 32, height: 32)
                .padding(.leading, 12)
                .padding(.top, 12)

                Spacer()

                Button(action: onLike) {
                    Image(systemName: entity.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(entity.isLiked ? .deepSprout : .gray0)
                }
                .frame(width: 32, height: 32)
                .padding(.trailing, 12)
                .padding(.top, 12)
            }
        }
    }
}

//#Preview {
//    let mockImages: [UIImage] = Array(repeating: makeGrayImage(size: CGSize(width: 400, height: 240)), count: 3)
//
//    let mockEntity = StoreImageCarouselEntity(
//        imageURLs: mockImages.map { _ in "https://mock.url/image.png" }, // 유효한 URL 필요 없음
//        isLiked: true
//    )
//
//    return StoreImageCarouselView(
//        entity: mockEntity,
//        onBack: { print("Back tapped") },
//        onLike: { print("Like tapped") }
//    )
//}

//fileprivate func makeGrayImage(size: CGSize) -> UIImage {
//    let renderer = UIGraphicsImageRenderer(size: size)
//    return renderer.image { context in
//        UIColor.lightGray.setFill()
//        context.fill(CGRect(origin: .zero, size: size))
//    }
//}
