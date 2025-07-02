//
//  AddressSearchAction.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

enum AddressSearchAction {
    enum Intent {
        case searchAddress(String)
        case clearResults
        case clearError
    }

    enum Result {
        case searchStarted
        case searchSucceeded([Location])
        case searchFailed(String)
        case resultsCleared
        case errorCleared
    }
}
