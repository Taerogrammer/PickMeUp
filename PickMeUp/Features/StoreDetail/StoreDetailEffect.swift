//
//  StoreDetailEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailEffect {
    func handle(_ action: StoreDetailAction.Intent, store: StoreDetailStore) {
        switch action {
        case .onAppear:
            Task {
                do {
                    let result = try await NetworkManager.shared.fetch(
                        StoreRouter.detail(query: StoreIDRequest(id: store.state.storeID)),
                        successType: StoreDetailResponse.self,
                        failureType: CommonMessageResponse.self
                    )

                    if let success = result.success {
                        await MainActor.run {
                            store.send(.fetchedStoreDetail(success))
                            store.send(.loadMenuImages(items: success.toState().entity.menuItems))
                        }
                    } else if let failure = result.failure {
                        print("❌ 서버 오류: \(failure.message)")
                    } else {
                        print("❌ 알 수 없는 오류: 응답이 비어 있음")
                    }
                } catch {
                    print("❌ 네트워크 오류: \(error.localizedDescription)")
                }
            }

        case .loadMenuImages(let items):
            for item in items {
                ImageLoader.load(from: item.menuImageURL, responder: MenuImageResponder(menuID: item.menuID, store: store))
            }

        default:
            break
        }
    }
}

final class MenuImageResponder: ImageLoadRespondable {
    private let menuID: String
    private let store: StoreDetailStore

    init(menuID: String, store: StoreDetailStore) {
        self.menuID = menuID
        self.store = store
    }

    func onImageLoaded(_ image: UIImage) {
        DispatchQueue.main.async {
            self.store.updateMenuImage(for: self.menuID, image: image)
        }
    }

    func onImageLoadFailed(_ errorMessage: String) {
        print("❌ \(menuID) 이미지 로딩 실패: \(errorMessage)")
    }
}
