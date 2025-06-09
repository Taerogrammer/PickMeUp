//
//  PaymentReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

struct PaymentReducer {
    func reduce(state: inout PaymentState, action: PaymentAction.Intent) {
        switch action {
        case .startPayment: break
        case .cancelPayment: break
        case .hideWebView: break
        case .dismissResult: break
        case .navigateBack: break
        }
    }

    func reduce(state: inout PaymentState, result: PaymentAction.Result) {
        switch result {
        case .paymentStarted:
            state.isPaymentInProgress = true

        case .webViewCreated(let webView):
            state.webView = webView

        case .webViewShown:
            state.showingWebView = true

        case .webViewHidden:
            state.showingWebView = false
            state.isPaymentInProgress = false

        case .paymentResponseReceived(let response):

        case .paymentSucceeded(let result):
            state.paymentResult = result

        case .paymentFailed(let result):
            state.paymentResult = result
            state.isPaymentInProgress = false

        case .verificationStarted:
            state.isVerifying = true

        case .verificationSucceeded(let response):
            state.isVerifying = false

        case .verificationFailed(let errorMessage):
            state.isVerifying = false

        case .resultShown(let result):
            state.paymentResult = result
            state.showingResult = true
            state.isPaymentInProgress = false
            state.isVerifying = false

        case .resultDismissed:
            state.showingResult = false
        }
    }
}
