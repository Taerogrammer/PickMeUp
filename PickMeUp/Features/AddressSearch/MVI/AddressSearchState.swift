//
//  AddressSearchState.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

struct AddressSearchState {
    var searchResults: [Location] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var hasSearched: Bool = false
}
