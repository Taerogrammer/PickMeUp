//
//  ProfileImageRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct ProfileImageRequest: Encodable {
    let imageData: Data
    let fileName: String
    let mimeType: String
}
