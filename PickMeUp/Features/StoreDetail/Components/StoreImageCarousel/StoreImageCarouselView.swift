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
                    AsyncImage(url: URL(string: entity.imageURLs[index])) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 240)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 240)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .frame(height: 240)
            .tabViewStyle(PageTabViewStyle())

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .padding(12)
                }

                Spacer()

                Button(action: onLike) {
                    Image(systemName: entity.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(entity.isLiked ? .red : .white)
                        .padding(12)
                }
            }
            .padding(.horizontal)
            .padding(.top, 48)
        }
    }
}

//#Preview {
//    let mockImages: [UIImage] = Array(repeating: makeGrayImage(size: CGSize(width: 400, height: 240)), count: 3)
//
//    let mockEntity = StoreImageCarouselEntity(
//        images: mockImages,
//        isLiked: true
//    )
//
//    return StoreImageCarouselView(
//        entity: mockEntity,
//        onBack: { print("back") },
//        onLike: { print("like") }
//    )
//}
//
//func makeGrayImage(size: CGSize) -> UIImage {
//    let renderer = UIGraphicsImageRenderer(size: size)
//    return renderer.image { context in
//        UIColor.lightGray.setFill()
//        context.fill(CGRect(origin: .zero, size: size))
//    }
//}
