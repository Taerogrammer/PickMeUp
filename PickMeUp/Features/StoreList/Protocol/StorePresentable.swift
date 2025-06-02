//
//  StorePresentable.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

protocol StorePresentable {
    var storeID: String { get }
    var category: String { get }
    var name: String { get }
    var close: String { get }
    var storeImageURLs: [String] { get }
    var isPicchelin: Bool { get }
    var isPick: Bool { get }
    var pickCount: Int { get }
    var hashTags: [String] { get }
    var totalRating: Double { get }
    var totalOrderCount: Int { get }
    var totalReviewCount: Int { get }
    var distance: Double { get }
}
