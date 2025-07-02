//
//  AddressSearchReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

struct AddressSearchReducer {
    func reduce(state: inout AddressSearchState, intent: AddressSearchAction.Intent) {
        switch intent {
        case .searchAddress:
            state.isLoading = true
            state.errorMessage = nil

        case .clearResults:
            state.searchResults = []
            state.hasSearched = false
            state.errorMessage = nil

        case .clearError:
            state.errorMessage = nil
        }
    }

    func reduce(state: inout AddressSearchState, result: AddressSearchAction.Result) {
        switch result {
        case .searchStarted:
            state.isLoading = true
            state.errorMessage = nil

        case .searchSucceeded(let results):
            state.searchResults = results
            state.isLoading = false
            state.hasSearched = true

        case .searchFailed(let error):
            state.errorMessage = error
            state.isLoading = false
            state.hasSearched = true

        case .resultsCleared:
            state.searchResults = []
            state.hasSearched = false
            state.errorMessage = nil

        case .errorCleared:
            state.errorMessage = nil
        }
    }
}
