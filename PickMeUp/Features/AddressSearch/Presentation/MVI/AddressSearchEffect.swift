//
//  AddressSearchEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

struct AddressSearchEffect {
    func handle(_ intent: AddressSearchAction.Intent, store: AddressSearchStore) {
        switch intent {
        case .searchAddress(let query):
            Task {
                await searchAddressFromNaverAPI(query: query, store: store)
            }
        case .clearResults:
            Task { @MainActor in
                store.send(.resultsCleared)
            }
        case .clearError:
            Task { @MainActor in
                store.send(.errorCleared)
            }
        }
    }

    private func searchAddressFromNaverAPI(query: String, store: AddressSearchStore) async {
        await MainActor.run {
            store.send(.searchStarted)
        }

        do {
            let results = try await NaverGeocodingService.shared.searchAddress(query: query)

            await MainActor.run {
                if results.isEmpty {
                    store.send(.searchFailed("검색 결과를 찾을 수 없습니다."))
                } else {
                    store.send(.searchSucceeded(results))
                }
            }
        } catch let error as NaverGeocodingError {
            await MainActor.run {
                store.send(.searchFailed(error.localizedDescription))
            }
        } catch {
            await MainActor.run {
                store.send(.searchFailed("네트워크 오류가 발생했습니다. 다시 시도해주세요."))
            }
        }
    }
}
