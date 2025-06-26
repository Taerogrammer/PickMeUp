//
//  LocationSelectionEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import Foundation

struct LocationSelectionEffect {
    func handle(_ intent: LocationSelectionAction.Intent, store: LocationSelectionStore) {
        switch intent {
        case .showLocationSelection:
            break // UI 상태만 변경

        case .selectLocation(let location):
            Task { @MainActor in
                store.send(.locationSelected(location))
            }

        case .dismissLocationSelection:
            break // UI 상태만 변경

        case .requestCurrentLocation:
            Task {
                await requestCurrentLocationFromService(store: store)
            }

        case .searchAddress(let query):
            Task {
                await searchAddressFromService(query: query, store: store)
            }

        case .addNewAddress:
            // 주소 추가 화면으로 이동 로직
            break

        case .editAddress(let address):
            Task { @MainActor in
                store.send(.addressEdited(address))
            }

        case .deleteAddress(let address):
            Task { @MainActor in
                store.send(.addressDeleted(address))
            }

        case .setDefaultAddress(let address):
            Task { @MainActor in
                store.send(.defaultAddressSet(address))
            }
        }
    }

    private func requestCurrentLocationFromService(store: LocationSelectionStore) async {
        await MainActor.run {
            store.send(.currentLocationRequestStarted)
        }

        // 시뮬레이션: 2초 후 성공
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 더미 데이터 사용
        let dummyCurrentLocation = LocationDummyData.defaultLocations.first(where: { $0.type == .system })?.address ?? "서울특별시 도봉구 방학로 310"

        await MainActor.run {
            store.send(.currentLocationRequestSucceeded(dummyCurrentLocation))
        }
    }

    private func searchAddressFromService(query: String, store: LocationSelectionStore) async {
        await MainActor.run {
            store.send(.addressSearchStarted)
        }

        // 시뮬레이션: 1초 후 성공
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 더미 데이터 사용
        let filteredResults = LocationDummyData.searchResults
            .filter { $0.displayAddress.contains(query) || query.isEmpty }
            .map { $0.displayAddress }

        let mockResults = filteredResults.isEmpty ? LocationDummyData.searchResults.map { $0.displayAddress } : filteredResults

        await MainActor.run {
            store.send(.addressSearchSucceeded(mockResults))
        }
    }
}
