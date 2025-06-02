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
                "https://images.unsplash.com/photo-1600891964599-f61ba0e24092",
                "/data/stores/alexandra-tran-oXULSch338E-unsplash_1747128618331.jpg",
                "/data/stores/d-pham-MU0pYUnrT68-unsplash_1747128618513.jpg",
                "/data/stores/deepthi-clicks--UUkXJIXgy4-unsplash_1747128618888.jpg"
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
                "/data/stores/alan-hardman-SU1LFoeEUkk-unsplash_1747128644203.jpg",
                "/data/stores/chad-montano-MqT0asuoIcU-unsplash_1747128644346.jpg",
                "/data/stores/shourav-sheikh-a66sGfOnnqQ-unsplash_1747128644500.jpg"
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
                "/data/stores/ante-samarzija-lsmu0rUhUOk-unsplash_1747128571997.jpg",
                "/data/stores/demi-deherrera-L-sm1B4L1Ns-unsplash_1747128572138.jpg",
                "/data/stores/jeremy-yap-jn-HaGWe4yw-unsplash_1747128572373.jpg"
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
                "/data/stores/ante-samarzija-lsmu0rUhUOk-unsplash_1747128571997.jpg",
                "/data/stores/demi-deherrera-L-sm1B4L1Ns-unsplash_1747128572138.jpg",
                "/data/stores/jeremy-yap-jn-HaGWe4yw-unsplash_1747128572373.jpg"
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
                "/data/stores/ante-samarzija-lsmu0rUhUOk-unsplash_1747128571997.jpg",
                "/data/stores/demi-deherrera-L-sm1B4L1Ns-unsplash_1747128572138.jpg",
                "/data/stores/jeremy-yap-jn-HaGWe4yw-unsplash_1747128572373.jpg"
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
