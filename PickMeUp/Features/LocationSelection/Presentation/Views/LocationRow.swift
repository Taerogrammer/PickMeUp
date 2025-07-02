//
//  LocationRow.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

struct LocationRow: View {
    let currentLocation: Location
    let onLocationTap: () -> Void

    var body: some View {
        Button(action: onLocationTap) {
            HStack(spacing: 8) {
                Image("annotation")
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(currentLocation.displayName)
                    .font(.pretendardBody1)
                    .foregroundColor(.gray90)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray90)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
