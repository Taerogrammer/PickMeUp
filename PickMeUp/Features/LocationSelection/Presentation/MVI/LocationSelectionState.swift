//
//  LocationSelectionState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct LocationSelectionState {
    var currentLocation: String = "씨드큐브 창동"
    var isShowingLocationSheet: Bool = false
    var isLoadingCurrentLocation: Bool = false
    var searchResults: [String] = []
    var savedAddresses: [String] = ["인천 부평구 마장로264번길 33 103 동 703호"]
    var defaultAddress: String = "씨드큐브 창동"
    var errorMessage: String?
    var isLoading: Bool = false

    init(
        currentLocation: String = "씨드큐브 창동",
        savedAddresses: [String] = ["인천 부평구 마장로264번길 33 103 동 703호"],
        defaultAddress: String = "씨드큐브 창동"
    ) {
        self.currentLocation = currentLocation
        self.savedAddresses = savedAddresses
        self.defaultAddress = defaultAddress
    }
}
