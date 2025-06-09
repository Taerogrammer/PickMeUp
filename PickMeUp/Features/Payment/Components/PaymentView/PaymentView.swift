//
//  PaymentView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import SwiftUI
import WebKit
import iamport_ios

struct PaymentView: View {
    @ObservedObject private var store: PaymentStore

    init(paymentInfo: PaymentInfo, router: AppRouter) {
        self.store = PaymentStore(paymentInfo: paymentInfo, router: router)
    }

    var body: some View {
        VStack(spacing: 20) {
            if store.state.showingWebView && store.state.webView != nil {
                WebViewRepresentable(webView: store.state.webView!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                OrderSummaryView(paymentInfo: store.state.paymentInfo)

                Spacer()

                Button(action: {
                    store.send(.startPayment)
                }) {
                    HStack {
                        if store.state.isPaymentInProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(store.state.paymentButtonTitle)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(store.state.isPaymentButtonDisabled)
                .padding()
            }
        }
        .navigationTitle("결제")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("취소") {
            if store.state.showingWebView {
                store.send(.cancelPayment)
            } else {
                store.send(.navigateBack)
            }
        })
        .sheet(isPresented: Binding(
            get: { store.state.showingResult },
            set: { _ in store.send(.dismissResult) }
        )) {
            PaymentResultView(
                result: store.state.paymentResult,
                onDismiss: {
                    store.send(.dismissResult)
                }
            )
        }
    }
}

//#Preview {
//    PaymentView()
//}
