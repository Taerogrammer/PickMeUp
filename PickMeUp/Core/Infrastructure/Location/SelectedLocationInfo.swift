//
//  SelectedLocationInfo.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import CoreLocation
import Foundation

struct SelectedLocationInfo: Equatable {
    let name: String
    let type: LocationType
    let latitude: Double
    let longitude: Double
    let address: String
    let detailAddress: String?

    var displayName: String {
        return name
    }

    var fullAddress: String {
        if let detail = detailAddress, !detail.isEmpty {
            return "\(address) \(detail)"
        }
        return address
    }

    var coordinates: (latitude: Double, longitude: Double) {
        return (latitude, longitude)
    }

    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    // Equatable 구현
    static func == (lhs: SelectedLocationInfo, rhs: SelectedLocationInfo) -> Bool {
        return lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.address == rhs.address &&
               lhs.detailAddress == rhs.detailAddress
    }
}
