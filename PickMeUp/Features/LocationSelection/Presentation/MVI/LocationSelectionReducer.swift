//
//  LocationSelectionReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct LocationSelectionReducer {
    func reduce(state: inout LocationSelectionState, action: LocationSelectionAction.Intent) {
        switch action {
        case .showLocationSelection:
            state.isShowingLocationSheet = true
            state.errorMessage = nil

        case .selectLocation:
            // Result에서 처리
            break

        case .dismissLocationSelection:
            state.isShowingLocationSheet = false
            state.isLoadingCurrentLocation = false
            state.isLoading = false

        case .requestCurrentLocation:
            state.isLoadingCurrentLocation = true
            state.errorMessage = nil

        case .searchAddress:
            state.isLoading = true
            state.errorMessage = nil

        case .addNewAddress, .editAddress, .deleteAddress, .setDefaultAddress:
            // Result에서 처리
            break
        }
    }

    func reduce(state: inout LocationSelectionState, result: LocationSelectionAction.Result) {
        switch result {
        case .locationSheetShown:
            state.isShowingLocationSheet = true
            state.errorMessage = nil

        case .locationSheetDismissed:
            state.isShowingLocationSheet = false
            state.isLoadingCurrentLocation = false
            state.isLoading = false

        case .locationSelected(let location):
            state.currentLocation = location  // 이제 Location 타입
            state.isShowingLocationSheet = false
            state.isLoadingCurrentLocation = false
            state.isLoading = false
            state.errorMessage = nil

        case .currentLocationRequestStarted:
            state.isLoadingCurrentLocation = true
            state.errorMessage = nil

        case .currentLocationRequestSucceeded(let location):
            state.currentLocation = location  // 이제 Location 타입
            state.isLoadingCurrentLocation = false
            state.isShowingLocationSheet = false
            state.errorMessage = nil

        case .currentLocationRequestFailed(let error):
            state.errorMessage = error
            state.isLoadingCurrentLocation = false

        case .addressSearchStarted:
            state.isLoading = true
            state.errorMessage = nil

        case .addressSearchSucceeded(let results):
            state.searchResults = results
            state.isLoading = false

        case .addressSearchFailed(let error):
            state.errorMessage = error
            state.isLoading = false

        case .addressAdded(let address):
            state.savedAddresses.append(address)

        case .addressEdited(let address):
            // 주소 편집 로직
            break

        case .addressDeleted(let address):
            state.savedAddresses.removeAll { $0 == address }

        case .defaultAddressSet(let address):
            state.defaultAddress = address
            if let location = LocationDummyData.defaultLocations.first(where: { $0.address == address }) {
                state.currentLocation = location
            }

        case .loadingStateChanged(let isLoading):
            state.isLoading = isLoading

        case .errorOccurred(let error):
            state.errorMessage = error
            state.isLoading = false
            state.isLoadingCurrentLocation = false
        }
    }
}
