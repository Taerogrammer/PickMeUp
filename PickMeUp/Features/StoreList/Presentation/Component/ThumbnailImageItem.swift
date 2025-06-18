//
//  ThumbnailImageItem.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import SwiftUI

struct ThumbnailImageItem: View {
    let image: UIImage?
    let imagePath: String?
    @State private var loadedImage: UIImage?

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
        .task {
            if let imagePath = imagePath, loadedImage == nil && image == nil {
                loadedImage = await ImageLoader.loadAsync(
                    from: imagePath,
                    targetSize: CGSize(width: 92, height: 62)
                )
            }
        }
    }
}
