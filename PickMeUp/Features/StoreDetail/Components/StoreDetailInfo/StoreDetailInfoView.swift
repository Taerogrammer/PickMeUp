//
//  StoreDetailInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreDetailInfoView: View {
    let entity: StoreDetailInfoEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(entity.address, systemImage: "mappin.and.ellipse")
            Label(entity.open, systemImage: "clock")
            Label(entity.parkingGuide, systemImage: "parkingsign.circle")
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
