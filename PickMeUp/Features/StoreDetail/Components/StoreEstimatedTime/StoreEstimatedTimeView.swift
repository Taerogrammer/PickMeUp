//
//  StoreEstimatedTimeView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreEstimatedTimeView: View {
    let entity: StoreEstimatedTimeEntity

    var body: some View {
        HStack {
            Label("예상 소요시간 \(entity.estimatedPickupTime) (\(entity.distance))", systemImage: "figure.walk")
                .font(.footnote)
                .foregroundColor(.orange)
            Spacer()
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    StoreEstimatedTimeView()
//}
