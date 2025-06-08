//
//  MenuDetailSheetView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/8/25.
//

import SwiftUI

struct MenuDetailSheetView: View {
    let menu: StoreMenuItemEntity
    let image: UIImage?
    @ObservedObject var cartManager: CartManager
    @State private var quantity = 1
    @Environment(\.dismiss) private var dismiss

    private var totalPrice: Int {
        menu.price * quantity
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 핸들바
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)

            // 메뉴 정보
            VStack(spacing: 12) {
                Text(menu.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(menu.description)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16)

                Text("\(menu.price.formatted())원")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)

            Spacer()

            // 수량 선택
            if !menu.isSoldOut {
                HStack(spacing: 24) {
                    Button {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    } label: {
                        Circle()
                            .fill(quantity > 1 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "minus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(quantity > 1 ? .black : .gray)
                            )
                    }
                    .disabled(quantity <= 1)

                    Text("\(quantity)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(minWidth: 40)

                    Button {
                        quantity += 1
                    } label: {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            // 하단 버튼
            Button {
                if !menu.isSoldOut {
                    cartManager.addToCart(menu: menu, quantity: quantity)
                    print("🛒 장바구니에 추가: \(menu.name) × \(quantity)")
                    dismiss()
                }
            } label: {
                Text(menu.isSoldOut ? "품절" : "담기 · \(totalPrice.formatted())원")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(menu.isSoldOut ? Color.gray : Color.blue)
                    )
            }
            .disabled(menu.isSoldOut)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .frame(maxHeight: 280)
        .onAppear {
            // 이미 장바구니에 있는 메뉴라면 해당 수량으로 설정
            quantity = cartManager.getQuantity(for: menu.menuID) > 0 ?
                       cartManager.getQuantity(for: menu.menuID) : 1
        }
    }
}

//#Preview {
//    MenuDetailSheetView()
//}



// MARK: - Cart Item Model
struct CartItem {
    let menu: StoreMenuItemEntity
    var quantity: Int

    var totalPrice: Int {
        return menu.price * quantity
    }
}

// MARK: - CartManager (ObservableObject)
class CartManager: ObservableObject {
    @Published var cartItems: [String: CartItem] = [:] // menuID를 키로 사용

    var totalPrice: Int {
        cartItems.values.reduce(0) { $0 + $1.totalPrice }
    }

    var itemCount: Int {
        cartItems.count // 메뉴 종류 수
    }

    func addToCart(menu: StoreMenuItemEntity, quantity: Int) {
        cartItems[menu.menuID] = CartItem(menu: menu, quantity: quantity)
    }

    func removeFromCart(menuID: String) {
        cartItems.removeValue(forKey: menuID)
    }

    func getQuantity(for menuID: String) -> Int {
        return cartItems[menuID]?.quantity ?? 0
    }

    func clearCart() {
        cartItems.removeAll()
    }
}
