//
//  PaymentResultView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import SwiftUI

struct PaymentResultView: View {
    let result: PaymentResultEntity?
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

//#Preview {
//    PaymentResultView(result: <#PaymentResult?#>, onDismiss: <#() -> Void#>)
//}
