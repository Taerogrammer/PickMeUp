//
//  PaymentStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

final class PaymentStore: ObservableObject {
    @Published private(set) var state: PaymentState
    private let effect: PaymentEffect
    private let reducer: PaymentReducer
    private let router: AppRouter

    init(paymentInfo: PaymentInfo, router: AppRouter) {
        self.state = PaymentState(paymentInfo: paymentInfo)
        self.effect = PaymentEffect()
        self.reducer = PaymentReducer()
        self.router = router
    }

    func send(_ action: PaymentAction.Intent) {
        reducer.reduce(state: &state, action: action)

        switch action {
        case .navigateBack:
            router.pop()
        case .dismissResult:
            if state.paymentResult?.isSuccess == true {
                router.reset()
            }
        default:
            break
        }

        effect.handle(action, store: self)
    }

    func send(_ result: PaymentAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
