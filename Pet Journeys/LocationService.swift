//
//  LocationService.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 19/05/24.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var location: CLLocation?

    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        checkIfLocationIsEnabled()
        if let initialLocation = locationManager?.location {
            let location = CLLocation(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)
            self.userLocation = initialLocation.coordinate
            self.location = location
            onLocationUpdate?(initialLocation.coordinate)
        }
        
        print("done")
    } 
    
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }

    private func checkIfLocationIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        } else {
            print("Show an alert letting them know this is off")
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location permission denied.")
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("PIndah")
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.userLocation = location.coordinate
            self.onLocationUpdate?(location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
}

extension CLLocationCoordinate2D {
    static let ducklings = CLLocationCoordinate2D(latitude: 42.35550, longitude: -71.06979)
}


