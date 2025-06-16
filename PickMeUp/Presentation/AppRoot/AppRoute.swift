//
//  AppRoute.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum AppRoute: Hashable {
    case register
    case editProfile(user: ProfileEntity)
    case storeDetail(storeID: String)
    case payment(PaymentInfoEntity)
}
