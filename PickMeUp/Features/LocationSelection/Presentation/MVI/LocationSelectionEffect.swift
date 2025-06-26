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
        // 실제 CoreLocation 서비스 호출
        await MainActor.run {
            store.send(.currentLocationRequestStarted)
        }

        // 시뮬레이션: 2초 후 성공
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        await MainActor.run {
            store.send(.currentLocationRequestSucceeded("현재 위치 - 서울시 강남구"))
        }
    }

    private func searchAddressFromService(query: String, store: LocationSelectionStore) async {
        // 실제 주소 검색 API 호출
        await MainActor.run {
            store.send(.addressSearchStarted)
        }

        // 시뮬레이션: 1초 후 성공
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let mockResults = [
            "\(query) 1번지",
            "\(query) 2번지",
            "\(query) 3번지"
        ]

        await MainActor.run {
            store.send(.addressSearchSucceeded(mockResults))
        }
    }
}
