//
//  StoreMockData.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreMockData {
    static let samples: [StoreListEntity] = [
        StoreListEntity(
            storeID: "68232364ca81ef0db5a4628d",
            category: "패스트푸드",
            name: "새싹 치킨 관악점",
            close: "22:00",
            storeImageURLs: [
                "https://picsum.photos/id/237/300/200",
                "https://picsum.photos/id/1025/300/200",
                "https://picsum.photos/id/1074/300/200"
            ],
            isPicchelin: true,
            isPick: true,
            pickCount: 2,
            hashTags: ["#오늘은치킨이닭"],
            totalRating: 0,
            totalOrderCount: 0,
            totalReviewCount: 0,
            distance: 12.7
        ),
        StoreListEntity(
            storeID: "68232b63ca81ef0db5a46483",
            category: "패스트푸드",
            name: "새싹 피자 창동점 2",
            close: "22:00",
            storeImageURLs: [
                "https://picsum.photos/id/1080/300/200",
                "https://picsum.photos/id/1084/300/200",
                "https://picsum.photos/id/1081/300/200"
            ],
            isPicchelin: false,
            isPick: false,
            pickCount: 2,
            hashTags: ["#도우맛집"],
            totalRating: 0,
            totalOrderCount: 0,
            totalReviewCount: 0,
            distance: 27.4
        ),
        StoreListEntity(
            storeID: "68231cb9ca81ef0db5a46063",
            category: "커피",
            name: "새싹 커피 2",
            close: "18:00",
            storeImageURLs: [
                "https://picsum.photos/id/1060/300/200",
                "https://picsum.photos/id/1062/300/200",
                "https://picsum.photos/id/1063/300/200"
            ],
            isPicchelin: false,
            isPick: false,
            pickCount: 4,
            hashTags: ["#소금빵맛집"],
            totalRating: 0,
            totalOrderCount: 0,
            totalReviewCount: 0,
            distance: 27.8
        ),
        StoreListEntity(
            storeID: "68231d1dca81ef0db5a4609b",
            category: "커피",
            name: "새싹 커피 10",
            close: "18:00",
            storeImageURLs: [
                "https://picsum.photos/id/1065/300/200",
                "https://picsum.photos/id/1066/300/200",
                "https://picsum.photos/id/1067/300/200"
            ],
            isPicchelin: true,
            isPick: true,
            pickCount: 2,
            hashTags: ["#소금빵맛집"],
            totalRating: 0,
            totalOrderCount: 0,
            totalReviewCount: 0,
            distance: 30.5
        ),
        StoreListEntity(
            storeID: "68231c58ca81ef0db5a46020",
            category: "커피",
            name: "새싹 커피 1",
            close: "18:00",
            storeImageURLs: [
                "https://picsum.photos/id/1068/300/200",
                "https://picsum.photos/id/1069/300/200",
                "https://picsum.photos/id/1070/300/200"
            ],
            isPicchelin: false,
            isPick: false,
            pickCount: 2,
            hashTags: ["#소금빵맛집"],
            totalRating: 0,
            totalOrderCount: 0,
            totalReviewCount: 0,
            distance: 35.9
        )
    ]
}
