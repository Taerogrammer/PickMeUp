//
//  ProfileImageView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI

struct ProfileImageView: View {
    let image: UIImage?
    let hasImage: Bool

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray45)
                    .padding(20)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color.gray0)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray30, lineWidth: 2))
        .shadow(radius: 4)
    }
}

//#Preview {
//    ProfileImageView()
//}
