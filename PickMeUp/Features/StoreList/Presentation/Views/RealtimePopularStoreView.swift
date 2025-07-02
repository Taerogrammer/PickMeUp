//
//  RealtimePopularStoreView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

struct RealtimePopularStoreView: View {
    let stores: [StorePresentable]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실시간 인기 맛집")
        }
    }
}

#Preview {
    RealtimePopularStoreView(stores: StoreMockData.samples)
}
