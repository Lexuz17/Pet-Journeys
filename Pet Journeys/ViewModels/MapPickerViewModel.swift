//
//  MapPickerViewModel.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 28/05/24.
//

import SwiftUI
import MapKit

class MapPickerViewModel: ObservableObject {
    
    @Published var mapType: MKMapType = .standard
    @Published var locationService = LocationService()
    @Published var mapCameraPosition: MapCameraPosition = .automatic
    @Published var mapVisibleRegion: MKCoordinateRegion?
    @Published var selectedMapItem: MKMapItem? // track user selected map items
    @Published var selectedMapItemTag: Int? // track user selected map items
    @Published var homeTappedCoordinate: CLLocationCoordinate2D?
    @Published var officeTappedCoordinate: CLLocationCoordinate2D?
    @Published var schoolTappedCoordinate: CLLocationCoordinate2D?
    @Published var TappedCoordinate: CLLocationCoordinate2D?
    @Published var queryResults: [MKMapItem] = [] // Store query results
    @Published var nearbyLocations: [MKMapItem] = [] // Store nearby locations
        
    // Set the maximum distance for the map region in meters
    let maxDistance: CLLocationDistance = 500
    
    var userLocation: CLLocationCoordinate2D? {
        guard let daLocation = locationService.location?.coordinate else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: daLocation.latitude, longitude: daLocation.longitude)
    }

    func markCoordinate(to coordinate: CLLocationCoordinate2D, type: String) {
        switch type {
        case "home":
            self.homeTappedCoordinate = coordinate
        case "office":
            self.officeTappedCoordinate = coordinate
        case "school":
            self.schoolTappedCoordinate = coordinate
        default:
            return
        }
        mapCameraPosition = .camera(MapCamera(centerCoordinate: coordinate, distance: maxDistance, heading: 0, pitch: 0))
    }
    
    func getTappedCoordinate(type: String) -> CLLocationCoordinate2D? {
        switch type {
        case "home":
            return homeTappedCoordinate
        case "office":
            return officeTappedCoordinate
        case "school":
            return schoolTappedCoordinate
        default:
            return nil
        }
    }
    
    func centerMapOnUserLocation() {
        guard let userLocation = userLocation else {
            return
        }
        mapCameraPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: maxDistance, heading: 0, pitch: 0))
    }
    
    func fetchQueryResults(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapVisibleRegion ?? MKCoordinateRegion()
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error fetching nearby locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.nearbyLocations = response.mapItems
            }
        }
    }
    
    func fetchNearbyLocations() {
        guard let userLocation = userLocation else { return }
        
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: userLocation, latitudinalMeters: maxDistance, longitudinalMeters: maxDistance)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error fetching nearby locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.nearbyLocations = response.mapItems
            }
        }
    }
}
