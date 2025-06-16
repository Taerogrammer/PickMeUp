//
//  PaymentAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation
import WebKit
import iamport_ios

enum PaymentAction {
    enum Intent {
        case startPayment
        case cancelPayment
        case hideWebView
        case dismissResult
        case navigateBack
    }

    enum Result {
        case paymentStarted
        case webViewCreated(WKWebView)
        case webViewShown
        case webViewHidden
        case paymentResponseReceived(IamportResponse?)
        case paymentSucceeded(PaymentResultEntity)
        case paymentFailed(PaymentResultEntity)
        case verificationStarted
        case verificationSucceeded(PaymentValidationResponse)
        case verificationFailed(String)
        case resultShown(PaymentResultEntity)
        case resultDismissed
    }
}
