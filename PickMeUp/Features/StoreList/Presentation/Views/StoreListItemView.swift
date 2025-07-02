//
//  StoreListItemView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListItemView: View, Equatable {
    @ObservedObject var store: StoreListStore
    let storeData: StorePresentable

    var loadedImages: [UIImage] {
        store.state.loadedImages[storeData.storeID] ?? []
    }

    // ✅ 기존 방식 생성자 (기존 코드와 호환)
    init(store: StoreListStore, storeData: StorePresentable) {
        self.store = store
        self.storeData = storeData
    }

    var body: some View {
        Button {
            store.send(.tapStore(storeID: storeData.storeID))
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    MainImageView(
                        image: loadedImages.first,
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
            store.send(.storeItemOnAppear(
                storeID: storeData.storeID,
                imagePaths: storeData.storeImageURLs
            ))
        }
    }

    static func == (lhs: StoreListItemView, rhs: StoreListItemView) -> Bool {
        lhs.storeData.storeID == rhs.storeData.storeID &&
        lhs.loadedImages.count == rhs.loadedImages.count
    }
}

private struct MainImageView: View, Equatable {
    let image: UIImage?
    var isPick: Bool
    var isPicchelin: Bool
    let imagePath: String?

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack(alignment: .topLeading) {
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
                    Color.gray30
                        .overlay(
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        )
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
            // ✅ 중복 로딩 방지 로직
            guard let imagePath = imagePath,
                  loadedImage == nil,
                  image == nil,
                  !isLoading else { return }

            isLoading = true
            loadedImage = await ImageLoader.loadAsync(
                from: imagePath,
                targetSize: CGSize(width: 260, height: 120)
            )
            isLoading = false
        }
    }

    static func == (lhs: MainImageView, rhs: MainImageView) -> Bool {
        lhs.imagePath == rhs.imagePath &&
        lhs.isPick == rhs.isPick &&
        lhs.isPicchelin == rhs.isPicchelin
    }
}

private struct ThumbnailImagesView: View, Equatable {
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

    static func == (lhs: ThumbnailImagesView, rhs: ThumbnailImagesView) -> Bool {
        lhs.imagePaths == rhs.imagePaths &&
        lhs.images.count == rhs.images.count
    }
}

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
        lhs.imagePath == rhs.imagePath &&
        (lhs.image != nil) == (rhs.image != nil)
    }
}

private struct InfoRowView: View, Equatable {
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

    static func == (lhs: InfoRowView, rhs: InfoRowView) -> Bool {
        lhs.storeData.storeID == rhs.storeData.storeID &&
        lhs.storeData.name == rhs.storeData.name &&
        lhs.storeData.pickCount == rhs.storeData.pickCount &&
        lhs.storeData.totalRating == rhs.storeData.totalRating &&
        lhs.storeData.totalReviewCount == rhs.storeData.totalReviewCount
    }
}

// MARK: - MetaRowView (최적화된 버전)
private struct MetaRowView: View, Equatable {
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

    static func == (lhs: MetaRowView, rhs: MetaRowView) -> Bool {
        lhs.storeData.storeID == rhs.storeData.storeID &&
        lhs.storeData.distance == rhs.storeData.distance &&
        lhs.storeData.close == rhs.storeData.close &&
        lhs.storeData.totalOrderCount == rhs.storeData.totalOrderCount
    }
}

// MARK: - HashTagsView (최적화된 버전)
private struct HashTagsView: View, Equatable {
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

    static func == (lhs: HashTagsView, rhs: HashTagsView) -> Bool {
        lhs.tags == rhs.tags
    }
}

// MARK: - IconText (최적화된 버전)
private struct IconText: View, Equatable {
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

    static func == (lhs: IconText, rhs: IconText) -> Bool {
        lhs.systemName == rhs.systemName &&
        lhs.text == rhs.text &&
        lhs.color == rhs.color
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
