//
//  StoreDetailStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

final class StoreDetailStore: ObservableObject {
    @Published private(set) var state: StoreDetailState
    private let effect: StoreDetailEffect
    private let reducer: StoreDetailReducer
    private let router: AppRouter


    init(state: StoreDetailState, effect: StoreDetailEffect, reducer: StoreDetailReducer, router: AppRouter) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
        self.router = router
    }

    func send(_ action: StoreDetailAction.Intent) {
        reducer.reduce(state: &state, action: action)
        switch action {
        case .tapBack:
            print(#function)
            router.pop()
        default: break
        }
        effect.handle(action, store: self)
    }

    func send(_ result: StoreDetailAction.Result) {
        reducer.reduce(state: &state, result: result)
    }

    func updateMenuImage(for menuID: String, image: UIImage) {
        state.loadedMenuImages[menuID] = image
    }
}
