//
//  FileRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

struct PostFileRequest: Encodable {
    let roomID: String
    let files: [String]
}
