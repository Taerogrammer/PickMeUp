//
//  PaymentEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import UIKit
import WebKit
import iamport_ios

struct PaymentEffect {
    func handle(_ action: PaymentAction.Intent, store: PaymentStore) {
        switch action {
        case .startPayment:
            Task {
                await executePayment(store: store)
            }

        case .cancelPayment:
            store.send(.webViewHidden)

        case .hideWebView:
            store.send(.webViewHidden)

        case .dismissResult:
            store.send(.resultDismissed)

        case .navigateBack:
            // 네비게이션은 View에서 처리
            break
        }
    }

    private func executePayment(store: PaymentStore) async {
        await MainActor.run {
            store.send(.paymentStarted)
        }

        // WKWebView는 메인 스레드에서 생성
        await MainActor.run {
            let wkWebView = WKWebView()
            wkWebView.backgroundColor = UIColor.clear

            store.send(.webViewCreated(wkWebView))
            store.send(.webViewShown)

            let environment = APIEnvironment.production
            // 포트원 결제 데이터 생성
            let payment = IamportPayment(
                pg: PG.html5_inicis.makePgRawName(pgId: environment.pgID),
                merchant_uid: store.state.paymentInfo.orderCode,
                amount: "\(store.state.paymentInfo.totalPrice)"
            ).then {
                $0.pay_method = PayMethod.card.rawValue
                $0.name = store.state.paymentInfo.storeName
                $0.buyer_name = environment.name
                $0.app_scheme = environment.appScheme
            }

            // 포트원 결제 실행
            Iamport.shared.paymentWebView(
                webViewMode: wkWebView,
                userCode: environment.portOneUserCode,
                payment: payment
            ) { iamportResponse in
                Task {
                    await MainActor.run {
                        store.send(.webViewHidden)
                        store.send(.paymentResponseReceived(iamportResponse))
                    }

                    await handlePaymentResponse(iamportResponse, store: store)
                }
            }
        }
    }

    private func handlePaymentResponse(_ response: IamportResponse?, store: PaymentStore) async {
        guard let response = response else {
            let failureResult = PaymentResult(
                isSuccess: false,
                impUID: nil,
                merchantUID: store.state.paymentInfo.orderCode,
                errorMessage: "결제 응답이 없습니다."
            )

            await MainActor.run {
                store.send(.paymentFailed(failureResult))
                store.send(.resultShown(failureResult))
            }
            return
        }

        if response.success == true {
            // 결제 성공
            let successResult = PaymentResult(
                isSuccess: true,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid ?? store.state.paymentInfo.orderCode,
                errorMessage: nil
            )

            await MainActor.run {
                store.send(.paymentSucceeded(successResult))
                store.send(.verificationStarted)
            }

            // 서버에 결제 검증 요청
            await verifyPayment(impUID: response.imp_uid ?? "", store: store)

        } else {
            // 결제 실패
            let failureResult = PaymentResult(
                isSuccess: false,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid ?? store.state.paymentInfo.orderCode,
                errorMessage: response.error_msg ?? "결제에 실패했습니다."
            )

            await MainActor.run {
                store.send(.paymentFailed(failureResult))
                store.send(.resultShown(failureResult))
            }
        }
    }

    private func verifyPayment(impUID: String, store: PaymentStore) async {
        print("💳 결제 검증 시작 - impUID: \(impUID)")

        let verifyRequest = PaymentValidationRequest(imp_uid: impUID)

        do {
            let result = try await NetworkManager.shared.fetch(
                PaymentRouter.verify(request: verifyRequest),
                successType: PaymentValidationResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                if let success = result.success {
                    print("✅ 결제 검증 완료: \(success)")
                    store.send(.verificationSucceeded(success))

                    // 검증 성공 시 결제 결과 업데이트
                    let finalResult = PaymentResult(
                        isSuccess: true,
                        impUID: store.state.paymentResult?.impUID,
                        merchantUID: store.state.paymentResult?.merchantUID ?? store.state.paymentInfo.orderCode,
                        errorMessage: nil
                    )
                    store.send(.resultShown(finalResult))

                } else if let failure = result.failure {
                    print("❌ 결제 검증 실패: \(failure.message)")
                    store.send(.verificationFailed(failure.message))

                    // 검증 실패 시 결제 실패 처리
                    let finalResult = PaymentResult(
                        isSuccess: false,
                        impUID: store.state.paymentResult?.impUID,
                        merchantUID: store.state.paymentResult?.merchantUID ?? store.state.paymentInfo.orderCode,
                        errorMessage: "결제 검증 실패: \(failure.message)"
                    )
                    store.send(.resultShown(finalResult))
                }
            }
        } catch {
            print("❌ 결제 검증 네트워크 오류: \(error)")
            await MainActor.run {
                store.send(.verificationFailed("네트워크 오류: \(error.localizedDescription)"))

                // 네트워크 오류 시 결제 실패 처리
                let finalResult = PaymentResult(
                    isSuccess: false,
                    impUID: store.state.paymentResult?.impUID,
                    merchantUID: store.state.paymentResult?.merchantUID ?? store.state.paymentInfo.orderCode,
                    errorMessage: "결제 검증 중 네트워크 오류가 발생했습니다."
                )
                store.send(.resultShown(finalResult))
            }
        }
    }
}
