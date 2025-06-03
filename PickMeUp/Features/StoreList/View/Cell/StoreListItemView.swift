//
//  StoreListItemView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListItemView: View {
    let storeData: StorePresentable
    let loadedImages: [UIImage]
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                MainImageView(image: loadedImages.first)
                ThumbnailImagesView(images: Array(loadedImages.dropFirst()))
            }
            .frame(maxWidth: .infinity, maxHeight: 128)

            InfoRowView(storeData: storeData)
            MetaRowView(storeData: storeData)
            HashTagsView(tags: storeData.hashTags)
        }
        .padding()
        .frame(height: 235)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear(perform: onAppear)
    }
}

private struct MainImageView: View {
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray30
            }
        }
        .frame(height: 128)
        .clipped()
        .cornerRadius(12)
    }
}

private struct ThumbnailImagesView: View {
    let images: [UIImage?]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { index in
                Group {
                    if index < images.count, let image = images[index] {
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
                .frame(width: 92, height: (128 - 4) / 2)
                .clipped()
                .cornerRadius(8)
            }
        }
    }
}

private struct InfoRowView: View {
    let storeData: StorePresentable

    var body: some View {
        HStack(spacing: 8) {
            Text(storeData.name)
                .font(.pretendardBody1)
                .foregroundColor(.gray100)

            IconText(systemName: "heart.fill", text: "\(storeData.pickCount)", color: .brightForsythia)
            IconText(systemName: "star.fill", text: String(format: "%.1f", storeData.totalRating), color: .brightForsythia)
            Text("(\(storeData.totalReviewCount))")
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)

            Spacer()
        }
    }
}

private struct MetaRowView: View {
    let storeData: StorePresentable

    private var formattedDistance: String {
        storeData.distance >= 1000
        ? String(format: "%.1fkm", storeData.distance / 1000)
        : String(format: "%.0fm", storeData.distance)
    }

    var body: some View {
        HStack(spacing: 8) {
            IconText(systemName: "paperplane.fill", text: formattedDistance, color: .deepSprout)
            IconText(systemName: "clock", text: storeData.close, color: .deepSprout)
            IconText(systemName: "figure.walk", text: "\(storeData.totalOrderCount)회", color: .blackSprout)
        }
    }
}

private struct HashTagsView: View {
    let tags: [String]

    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.pretendardCaption2)
                    .foregroundColor(.gray100)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.deepSprout)
                    .cornerRadius(8)
            }
        }
    }
}

private struct IconText: View {
    let systemName: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: systemName)
                .foregroundColor(color)
            Text(text)
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)
        }
    }
}

//#Preview {
//    StoreListItemView(storeData: StoreMockData.samples[0])
//}
