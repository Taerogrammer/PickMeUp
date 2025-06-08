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
    let cartQuantity: Int
    let onRemove: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(menu.name)
                        .font(.pretendardBody1)
                        .foregroundColor(.gray90)
                        .lineLimit(1)

                    Spacer()

                    // 장바구니에 담긴 경우 수량과 삭제 버튼 표시
                    if cartQuantity > 0 {
                        HStack(spacing: 8) {
                            // 수량 표시
                            Text("\(cartQuantity)")
                                .font(.pretendardCaption1)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Circle().fill(Color.blue))

                            // 삭제 버튼
                            Button {
                                onRemove()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }

                Text(menu.description)
                    .font(.pretendardCaption1)
                    .foregroundColor(.gray60)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 4)

                Text("\(menu.price.formatted())원")
                    .font(.pretendardBody1)
                    .foregroundColor(.gray90)
            }

            Spacer()

            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                }

                if menu.isSoldOut {
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                        .overlay(
                            Text("품절")
                                .font(.pretendardBody1)
                                .foregroundColor(.gray0)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(height: 130)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cartQuantity > 0 ? Color.blue.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cartQuantity > 0 ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle()) // 전체 영역 탭 가능하게
        .onTapGesture {
            onTap()
        }
    }
}

//#Preview {
//    VStack(spacing: 0) {
//        // 일반 메뉴
//        StoreMenuItemCardView(
//            menu: StoreMenuItemEntity(
//                menuID: "menu_001",
//                storeID: "store_123",
//                category: "디저트",
//                name: "올리브 츄이스티 도넛",
//                description: "올리브 오일을 듬뿍 사용한 바삭한 고소하면서도, 손으로 잡아먹는 재미까지 느낄 수 있어요.",
//                originInformation: "브라질산 원두 100%",
//                price: 3700,
//                isSoldOut: false,
//                menuImageURL: "https://example.com/donut.jpg"
//            ),
//            image: UIImage(systemName: "birthday.cake.fill")
//        )
//
//        Divider()
//
//        // 품절 메뉴
//        StoreMenuItemCardView(
//            menu: StoreMenuItemEntity(
//                menuID: "menu_002",
//                storeID: "store_123",
//                category: "디저트",
//                name: "올리브 츄이스티 도넛",
//                description: "올리브 오일을 듬뿍 사용한 바삭한 고소하면서도, 손으로 잡아먹는 재미까지 느낄 수 있어요.",
//                originInformation: "브라질산 원두, 국내산 우유",
//                price: 3700,
//                isSoldOut: true,
//                menuImageURL: "https://example.com/donut.jpg"
//            ),
//            image: UIImage(systemName: "birthday.cake.fill")
//        )
//
//        Divider()
//
//        // 이미지 로딩 중인 메뉴
//        StoreMenuItemCardView(
//            menu: StoreMenuItemEntity(
//                menuID: "menu_003",
//                storeID: "store_123",
//                category: "디저트",
//                name: "올리브 츄이스티 도넛",
//                description: "올리브 오일을 듬뿍 사용한 바삭한 고소하면서도, 손으로 잡아먹는 재미까지 느낄 수 있어요.",
//                originInformation: "덴마크산 크림치즈",
//                price: 3700,
//                isSoldOut: false,
//                menuImageURL: "https://example.com/donut.jpg"
//            ),
//            image: nil
//        )
//
//        Spacer()
//    }
//}
