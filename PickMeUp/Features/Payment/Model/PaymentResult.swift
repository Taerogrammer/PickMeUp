//
//  PaymentResult.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

struct PaymentResult {
    let isSuccess: Bool
    let impUID: String?
    let merchantUID: String
    let errorMessage: String?
}
