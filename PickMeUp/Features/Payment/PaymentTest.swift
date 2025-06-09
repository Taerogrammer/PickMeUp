//
//  PaymentTest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//
// MARK: - 1. 결제 관련 모델 추가

import SwiftUI
import WebKit
import iamport_ios

// 결제 정보 모델
struct PaymentInfo: Equatable, Hashable {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let storeName: String
    let menuItems: [CartItem]
    let createdAt: String
}

// 결제 결과 모델
struct PaymentResult {
    let isSuccess: Bool
    let impUID: String?
    let merchantUID: String
    let errorMessage: String?
}

// MARK: - PaymentView
struct PaymentView: View {
    let paymentInfo: PaymentInfo
    @ObservedObject var router: AppRouter
    @State private var isPaymentInProgress = false
    @State private var paymentResult: PaymentResult?
    @State private var showingResult = false
    @State private var showingWebView = false  // 🚀 추가

    // 🚀 WKWebView를 @State로 관리
    @State private var webView: WKWebView?

    var body: some View {
        VStack(spacing: 20) {
            if showingWebView && webView != nil {
                // 🚀 결제 WebView 표시
                WebViewRepresentable(webView: webView!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 주문 정보 표시
                OrderSummaryView(paymentInfo: paymentInfo)

                Spacer()

                // 결제 버튼
                Button(action: {
                    startPayment()
                }) {
                    HStack {
                        if isPaymentInProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isPaymentInProgress ? "결제 진행 중..." : "결제하기")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isPaymentInProgress)
                .padding()
            }
        }
        .navigationTitle("결제")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("취소") {
            if showingWebView {
                // 결제 중일 때는 WebView만 숨김
                showingWebView = false
                isPaymentInProgress = false
            } else {
                // 일반적인 뒤로가기
                router.pop()
            }
        })
        .sheet(isPresented: $showingResult) {
            PaymentResultView(
                result: paymentResult,
                onDismiss: {
                    showingResult = false
                    if paymentResult?.isSuccess == true {
                        router.reset()
                    }
                }
            )
        }
    }

    // MARK: - 결제 시작
    private func startPayment() {
        isPaymentInProgress = true
        showingWebView = true  // 🚀 WebView 표시

        // 🚀 WKWebView 생성
        let wkWebView = WKWebView()
        wkWebView.backgroundColor = UIColor.clear
        self.webView = wkWebView

        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: paymentInfo.orderCode,
            amount: "\(paymentInfo.totalPrice)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = "\(paymentInfo.storeName)"
            $0.buyer_name = "김태형"
            $0.app_scheme = "pickmeup"
        }

        // 포트원 결제 실행
        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: "imp14511373",
            payment: payment
        ) { iamportResponse in
            DispatchQueue.main.async {
                self.showingWebView = false  // 🚀 WebView 숨김
                self.handlePaymentResponse(iamportResponse)
            }
        }
    }

    // MARK: - 결제 응답 처리
    private func handlePaymentResponse(_ response: IamportResponse?) {
        isPaymentInProgress = false

        guard let response = response else {
            paymentResult = PaymentResult(
                isSuccess: false,
                impUID: nil,
                merchantUID: paymentInfo.orderCode,
                errorMessage: "결제 응답이 없습니다."
            )
            showingResult = true
            return
        }

        if response.success == true {
            // 결제 성공
            paymentResult = PaymentResult(
                isSuccess: true,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid ?? paymentInfo.orderCode,
                errorMessage: nil
            )

            // 서버에 결제 검증 요청
            Task {
                await verifyPayment(impUID: response.imp_uid ?? "", merchantUID: response.merchant_uid ?? "")
            }
        } else {
            // 결제 실패
            paymentResult = PaymentResult(
                isSuccess: false,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid ?? paymentInfo.orderCode,
                errorMessage: response.error_msg ?? "결제에 실패했습니다."
            )
        }

        showingResult = true
    }

    // MARK: - 결제 검증
    private func verifyPayment(impUID: String, merchantUID: String) async {
        print("💳 결제 검증 시작 - impUID: \(impUID), merchantUID: \(merchantUID)")

        // 결제 검증 요청 데이터
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
                    // 검증 성공 시 결제 결과 업데이트
                    if let currentResult = paymentResult {
                        paymentResult = PaymentResult(
                            isSuccess: true,
                            impUID: currentResult.impUID,
                            merchantUID: currentResult.merchantUID,
                            errorMessage: nil
                        )
                    }
                } else if let failure = result.failure {
                    print("❌ 결제 검증 실패: \(failure.message)")
                    // 검증 실패 시 결제 실패 처리
                    if let currentResult = paymentResult {
                        paymentResult = PaymentResult(
                            isSuccess: false,
                            impUID: currentResult.impUID,
                            merchantUID: currentResult.merchantUID,
                            errorMessage: "결제 검증 실패: \(failure.message)"
                        )
                    }
                }
            }
        } catch {
            print("❌ 결제 검증 네트워크 오류: \(error)")
            await MainActor.run {
                // 네트워크 오류 시 결제 실패 처리
                if let currentResult = paymentResult {
                    paymentResult = PaymentResult(
                        isSuccess: false,
                        impUID: currentResult.impUID,
                        merchantUID: currentResult.merchantUID,
                        errorMessage: "결제 검증 중 네트워크 오류가 발생했습니다."
                    )
                }
            }
        }
    }
}

// MARK: - WKWebView SwiftUI Wrapper
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 업데이트가 필요한 경우 구현
    }
}

// MARK: - 주문 요약 뷰
struct OrderSummaryView: View {
    let paymentInfo: PaymentInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주문 정보")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("주문 번호:")
                    Spacer()
                    Text(paymentInfo.orderCode)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("매장:")
                    Spacer()
                    Text(paymentInfo.storeName)
                        .fontWeight(.medium)
                }
            }

            Divider()

            Text("주문 메뉴")
                .font(.headline)

            ForEach(paymentInfo.menuItems.indices, id: \.self) { index in
                let item = paymentInfo.menuItems[index]
                HStack {
                    Text(item.menu.name)
                    Spacer()
                    Text("\(item.quantity)개")
                    Text("\(item.totalPrice)원")
                        .fontWeight(.medium)
                }
            }

            Divider()

            HStack {
                Text("총 결제 금액")
                    .font(.headline)
                Spacer()
                Text("\(paymentInfo.totalPrice)원")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - 결제 결과 뷰
struct PaymentResultView: View {
    let result: PaymentResult?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: result?.isSuccess == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(result?.isSuccess == true ? .green : .red)

            Text(result?.isSuccess == true ? "결제 완료" : "결제 실패")
                .font(.title)
                .fontWeight(.bold)

            if let result = result {
                if result.isSuccess {
                    Text("결제가 성공적으로 완료되었습니다.")
                        .multilineTextAlignment(.center)

                    if let impUID = result.impUID {
                        Text("결제 번호: \(impUID)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(result.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
            }

            Button("확인") {
                onDismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 미리보기
struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePaymentInfo = PaymentInfo(
            orderID: "test-order-id",
            orderCode: "TEST123",
            totalPrice: 15000,
            storeName: "테스트 매장",
            menuItems: [],
            createdAt: "2025-06-09T05:33:27.315Z"
        )

        // AppRouter의 mock 인스턴스가 필요합니다
        // PaymentView(paymentInfo: samplePaymentInfo, router: MockAppRouter())
        Text("PaymentView Preview")
    }
}
