//
//  LocationSelectionAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

enum LocationSelectionAction {
    enum Intent {
        case showLocationSelection
        case selectLocation(Location)
        case dismissLocationSelection
        case requestCurrentLocation
        case searchAddress(String)
        case addNewAddress
        case editAddress(String)
        case deleteAddress(String)
        case setDefaultAddress(String)
    }

    enum Result {
        case locationSheetShown
        case locationSheetDismissed
        case locationSelected(Location)  // String → Location
        case currentLocationRequestStarted
        case currentLocationRequestSucceeded(Location)  // String → Location
        case currentLocationRequestFailed(String)
        case addressSearchStarted
        case addressSearchSucceeded([String])
        case addressSearchFailed(String)
        case addressAdded(String)
        case addressEdited(String)
        case addressDeleted(String)
        case defaultAddressSet(String)
        case loadingStateChanged(Bool)
        case errorOccurred(String)
    }
}
