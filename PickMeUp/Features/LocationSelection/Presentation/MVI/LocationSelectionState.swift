//
//  LocationSelectionState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct LocationSelectionState {
    var currentLocation: Location
    var isShowingLocationSheet: Bool = false
    var isLoadingCurrentLocation: Bool = false
    var searchResults: [String] = []
    var savedAddresses: [String]
    var defaultAddress: String
    var errorMessage: String?
    var isLoading: Bool = false

    init() {
        let dummyLocations = LocationDummyData.defaultLocations
        let homeLocation = dummyLocations.first(where: { $0.type == .home }) ?? dummyLocations.first!

        self.currentLocation = homeLocation
        self.savedAddresses = dummyLocations.map { $0.address }
        self.defaultAddress = homeLocation.address
    }
}
