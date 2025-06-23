//
//  CachedMetaData.swift
//  PickMeUp
//
//  Created by 김태형 on 6/18/25.
//

import Foundation

// MARK: - 캐시 메타 데이터 (디스크 저장)
struct CacheMetaData: Codable {
    let etag: String
    let lastModified: Date
    let fileSize: Int
    let imagePath: String
    var lastAccessDate: Date = Date()
}
