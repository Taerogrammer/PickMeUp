//
//  ThumbnailImageItem.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import SwiftUI

private struct ThumbnailImageItem: View, Equatable {
    let image: UIImage?
    let imagePath: String?

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFill()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.gray30
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(.gray60)
                            Text("No Image")
                                .font(.caption2)
                                .foregroundColor(.gray60)
                        }
                    }
                }
            }
        }
        .task {
            // ✅ 중복 로딩 방지
            guard let imagePath = imagePath,
                  loadedImage == nil,
                  image == nil,
                  !isLoading else { return }

            isLoading = true
            loadedImage = await ImageLoader.loadAsync(
                from: imagePath,
                targetSize: CGSize(width: 92, height: 62)
            )
            isLoading = false
        }
    }

    static func == (lhs: ThumbnailImageItem, rhs: ThumbnailImageItem) -> Bool {
        return lhs.imagePath == rhs.imagePath &&
               (lhs.image != nil) == (rhs.image != nil)  // ← 괄호로 명확하게 구분
    }
}
