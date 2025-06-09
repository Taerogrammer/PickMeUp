//
//  PaymentState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation
import WebKit

struct PaymentState {
    let paymentInfo: PaymentInfo
    var isPaymentInProgress: Bool = false
    var paymentResult: PaymentResult?
    var showingResult: Bool = false
    var showingWebView: Bool = false
    var webView: WKWebView?
    var isVerifying: Bool = false

    var isNavigationBackButtonEnabled: Bool {
        return !isPaymentInProgress
    }

    var paymentButtonTitle: String {
        return isPaymentInProgress ? "결제 진행 중..." : "결제하기"
    }

    var isPaymentButtonDisabled: Bool {
        return isPaymentInProgress
    }
}
