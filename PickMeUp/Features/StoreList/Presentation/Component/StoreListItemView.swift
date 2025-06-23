//
//  StoreListItemView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListItemView: View {
    @ObservedObject var store: StoreListStore
    let storeData: StorePresentable

    var loadedImages: [UIImage] {
        store.state.loadedImages[storeData.storeID] ?? []
    }

    var body: some View {
        Button {
            store.send(.tapStore(storeID: storeData.storeID))
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    MainImageView(
                        image: store.state.loadedImages[storeData.storeID]?.first,
                        isPick: storeData.isPick,
                        isPicchelin: storeData.isPicchelin,
                        imagePath: storeData.storeImageURLs.first
                    )
                    ThumbnailImagesView(
                        images: Array(loadedImages.dropFirst()),
                        imagePaths: Array(storeData.storeImageURLs.dropFirst())
                    )
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
        }
        .buttonStyle(.plain)
        .onAppear {
            // 🔄 변경: 기존 코드 유지하되, 캐시 시스템이 백그라운드에서 작동
            store.send(.storeItemOnAppear(
                storeID: storeData.storeID,
                imagePaths: storeData.storeImageURLs
            ))
        }
    }
}

private struct MainImageView: View {
    let image: UIImage?
    var isPick: Bool
    var isPicchelin: Bool

    @State private var loadedImage: UIImage?
    let imagePath: String? // 🆕 이미지 경로 추가

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                // 🔄 변경: loadedImage 우선 사용, 없으면 기존 image 사용
                if let loadedImage = loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFill()
                } else if let image = image {
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

            HStack {
                if isPick {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.deepSprout)
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.gray0)
                }

                Spacer()

                if isPicchelin {
                    PickchelinConcaveRibbonView()
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
        }
        .frame(height: 128)
        .cornerRadius(12)
        .clipped()
        .task {
            if let imagePath = imagePath, loadedImage == nil && image == nil {
                loadedImage = await ImageLoader.loadAsync(
                    from: imagePath,
                    targetSize: CGSize(width: 260, height: 120)
                )
            }
        }
    }
}


private struct ThumbnailImagesView: View {
    let images: [UIImage?]
    let imagePaths: [String]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { index in
                ThumbnailImageItem(
                    image: index < images.count ? images[index] : nil,
                    imagePath: index < imagePaths.count ? imagePaths[index] : nil
                )
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

#Preview {
    let mockStore = StoreListStore(
        initialState: StoreListState(
            stores: StoreMockData.samples,
            loadedImages: [
                StoreMockData.samples[0].storeID: [
                    UIImage(systemName: "photo")!,
                    UIImage(systemName: "photo.fill")!
                ]
            ],
            selectedCategory: "전체"
        )
    )

    return StoreListItemView(
        store: mockStore,
        storeData: StoreMockData.samples[0]
    )
}
