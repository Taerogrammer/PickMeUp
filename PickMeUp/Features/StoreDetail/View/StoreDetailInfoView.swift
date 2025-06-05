//
//  StoreDetailInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreDetailInfoView: View {
    let address: String
    let time: String
    let parking: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(address, systemImage: "mappin.and.ellipse")
            Label(time, systemImage: "clock")
            Label(parking, systemImage: "parkingsign.circle")
        }
        .font(.footnote)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

//#Preview {
//    StoreDetailInfoView()
//}
