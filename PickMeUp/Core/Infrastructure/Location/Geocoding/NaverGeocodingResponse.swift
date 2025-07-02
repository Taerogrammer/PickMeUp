//
//  NaverGeocodingResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

// MARK: - 네이버 지오코딩 응답 모델
struct NaverGeocodingResponse: Codable {
    let status: String
    let meta: Meta
    let addresses: [Address]
    let errorMessage: String?

    struct Meta: Codable {
        let totalCount: Int
        let page: Int
        let count: Int
    }

    struct Address: Codable {
        let roadAddress: String?
        let jibunAddress: String?
        let englishAddress: String?
        let addressElements: [AddressElement]
        let x: String // 경도
        let y: String // 위도
        let distance: Double?

        struct AddressElement: Codable {
            let types: [String]
            let longName: String
            let shortName: String
            let code: String?
        }
    }
}
