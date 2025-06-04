//
//  StoreDetailScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailScreen: View {
    let storeID: String

    var body: some View {
        VStack(spacing: 20) {
            Text("가게 상세화면")
                .font(.largeTitle)
                .bold()

            Text("Store ID: \(storeID)")
                .font(.title2)

            Spacer()
        }
        .padding()
        .navigationTitle("가게 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StoreDetailScreen(storeID: "asdq")
}
