//
//  PaymentOrderResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

struct PaymentOrderResponse: Decodable {
   let imp_uid: String
   let merchant_uid: String
   let pay_method: String
   let channel: String
   let pg_provider: String
   let emb_pg_provider: String
   let pg_tid: String
   let pg_id: String
   let escrow: Bool
   let apply_num: String
   let bank_code: String
   let bank_name: String
   let card_code: String
   let card_name: String
   let card_issuer_code: String
   let card_issuer_name: String
   let card_publisher_code: String
   let card_publisher_name: String
   let card_quota: Int
   let card_number: String
   let card_type: Int
   let vbank_code: String
   let vbank_name: String
   let vbank_num: String
   let vbank_holder: String
   let vbank_date: Int
   let vbank_issued_at: Int
   let name: String
   let amount: Int
   let currency: String
   let buyer_name: String
   let buyer_email: String
   let buyer_tel: String
   let buyer_addr: String
   let buyer_postcode: String
   let custom_data: String
   let user_agent: String
   let status: String
   let startedAt: String
   let paidAt: String
   let receipt_url: String
   let createdAt: String
   let updatedAt: String
}
