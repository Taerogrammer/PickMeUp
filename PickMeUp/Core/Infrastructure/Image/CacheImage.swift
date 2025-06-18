//
//  CachedImage.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import SwiftUI

// MARK: - 캐시된 이미지 모델
class CacheImage {
    let image: UIImage
    let etag: String
    let lastModified: Date
    let fileSize: Int
    let downloadDate: Date

    init(image: UIImage, etag: String, lastModified: Date = Date(), fileSize: Int) {
        self.image = image
        self.etag = etag
        self.lastModified = lastModified
        self.fileSize = fileSize
        self.downloadDate = Date()
    }
}
