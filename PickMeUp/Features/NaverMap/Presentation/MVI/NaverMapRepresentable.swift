//
//  NaverMapRepresentable.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import CoreLocation
import SwiftUI

struct NaverMapRepresentable: UIViewRepresentable {
    let initialLocation: CLLocationCoordinate2D?
    let currentLocation: CLLocationCoordinate2D?
    let onLocationConfirmed: (CLLocationCoordinate2D, String) -> Void
    let onDismiss: () -> Void
    let onCurrentLocationRequested: (() -> Void)?

    func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        return coordinator.createMapContainer()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateCurrentLocation(currentLocation)
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(
            initialLocation: initialLocation,
            currentLocation: currentLocation,
            onLocationConfirmed: onLocationConfirmed,
            onDismiss: onDismiss,
            onCurrentLocationRequested: onCurrentLocationRequested
        )
    }
}
