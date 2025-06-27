//
//  LocationSelectionState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct LocationSelectionState {
    var currentLocation: String
    var isShowingLocationSheet: Bool = false
    var isLoadingCurrentLocation: Bool = false
    var searchResults: [String] = []
    var savedAddresses: [String]
    var defaultAddress: String
    var errorMessage: String?
    var isLoading: Bool = false

    init() {
        // 더미 데이터 사용
        let dummyLocations = LocationDummyData.defaultLocations
        let homeLocation = dummyLocations.first(where: { $0.type == .home })
        let defaultLocation = homeLocation?.address ?? dummyLocations.first?.address ?? "인천광역시 부평구 마장로264번길 33"

        self.currentLocation = defaultLocation
        self.savedAddresses = dummyLocations.map { $0.address }
        self.defaultAddress = defaultLocation
    }
}
