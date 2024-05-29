//
//  ContentViewModel.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 15/05/24.
//

import SwiftUI
import CoreLocation
import MapKit

class ContentViewModel: NSObject, ObservableObject {
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -6.302087, longitude: 106.652060), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    @Published var userLocation: CLLocationCoordinate2D? {
        didSet {
            if let userLocation = userLocation {
                print("Kacao")
                fetchAllLocations(lat: Float(userLocation.latitude), lng: Float(userLocation.longitude), radius: 500)
            }
        }
    }
    
    @Published var restaurantLocations: [LocationModel]?
    @Published var clothingStoreLocations: [LocationModel]?
    @Published var hospitalLocations: [LocationModel]?
    @Published var moodLocations: [LocationModel]?
    @Published var dataFetched: Bool = false
    
    @ObservedObject var dogVM = DogVM()
    //    @Published var pet: Pet?
    
    private var locationService: LocationService
    private var healthTimer: Timer?
    private let targetLatitude: CLLocationDegrees = -6.124506
    private let targetLongitude: CLLocationDegrees = 106.797019
    private let threshold: CLLocationDistance = 30.0 // in meters
    
    var isNearRestaurant: Bool = false
    var isNearHospital: Bool = false
    var isNearStore: Bool = false
    var isNearPlayground: Bool = false
    var isNearHouse: Bool = false
    var isNearOffice: Bool = false
    
    var binding: Binding<MKCoordinateRegion> {
        Binding {
            self.mapRegion
        } set: { newRegion in
            self.mapRegion = newRegion
        }
    }
    
    func updateMapRegion(_ coordinate: CLLocationCoordinate2D) {
        // Update the map region based on the new location
        let newRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        self.mapRegion = newRegion
    }
    
    init(dogVM: DogVM) {
        self.dogVM = dogVM
        self.locationService = LocationService()
        super.init()
        
        self.locationService.onLocationUpdate = { [weak self] newLocation in
            self?.updateMapRegion(newLocation)
            self?.handleLocationUpdate(newLocation)
            self?.startMonitoringRestaurantDuration()
        }
        self.locationService.startUpdatingLocation()  // Mulai update lokasi
        
        // Fetch initial location data if available
        if let initialLocation = self.locationService.userLocation {
            self.updateMapRegion(initialLocation)
            self.handleLocationUpdate(initialLocation)
            self.startMonitoringRestaurantDuration()
        }
    }
    //    func createPet(type: String, name: String) {
    //        switch type {
    //        case "Dog":
    //            self.pet = Dog(name: name)
    //        case "Cat":
    //            self.pet = Cat(name: name)
    //        default:
    //            breakd
    //        }
    //    }
    
    private func handleLocationUpdate(_ newLocation: CLLocationCoordinate2D) {
        print("handleLocationUpdate")
        print(isNearRestaurant)
        print(isNearHospital)
        print(isNearStore)
        // Check if the user is at the specific coordinates
        self.userLocation = newLocation
        
        checkNearbyRestaurants()
        checkNearbyHospital()
        checkNearbyPlayground()
        checkNearbyStore()
        
        //
        //        let currentLocation = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        //        let targetLocation = CLLocation(latitude: targetLatitude, longitude: targetLongitude)
        //
        //        let distance = currentLocation.distance(from: targetLocation)
        //
        //        if distance <= threshold {
        //            startHealthTimer()
        //        } else {
        //            stopHealthTimer()
        //        }
        if isNearRestaurant || isNearHouse || isNearPlayground || isNearHospital {
            startHealthTimer()
        }
        else{
            stopHealthTimer()
        }
    }
    
    private func startHealthTimer() {
        guard healthTimer == nil else { return }
        healthTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.isNearRestaurant == true {
                self?.increasePetHunger()
            }
            if self?.isNearPlayground == true {
                self?.increasePetMood()
            }
            if self?.isNearHospital == true {
                self?.increasePetHealth()
            }
            if self?.isNearHouse == true {
                self?.increasePetEnergy()
            }
        }
    }
    
    private func stopHealthTimer() {
        healthTimer?.invalidate()
        healthTimer = nil
    }
    
    private func increasePetHealth() {
        DispatchQueue.main.async {
            self.dogVM.incrementStat(.health)
            if self.dogVM.dog.healthStat > 100 {
                self.dogVM.dog.healthStat = 100
            }
            print("Pet's health increase to \(self.dogVM.dog.healthStat)")
        }
    }
    
    private func increasePetHunger() {
        DispatchQueue.main.async {
            self.dogVM.incrementStat(.hunger)
            if self.dogVM.dog.foodStat > 100 {
                self.dogVM.dog.foodStat = 100
            }
            print("Pet's hunger increase to \(self.dogVM.dog.foodStat)")
        }
    }
    private func increasePetMood() {
        DispatchQueue.main.async {
            self.dogVM.incrementStat(.mood)
            if self.dogVM.dog.moodStat > 100 {
                self.dogVM.dog.moodStat = 100
            }
            print("Pet's mood increase to \(self.dogVM.dog.moodStat)")
        }
    }
    private func increasePetEnergy() {
        DispatchQueue.main.async {
            self.dogVM.incrementStat(.energy)
            if self.dogVM.dog.energyStat > 100 {
                self.dogVM.dog.energyStat = 100
            }
            print("Pet's energy increase to \(self.dogVM.dog.energyStat)")
        }
    }
    
    private func startMonitoringRestaurantDuration() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if !self.isNearRestaurant {
                self.decreasePetHunger()
            }
        }
    }
    
    private func decreasePetHunger() {
        DispatchQueue.main.async {
            self.dogVM.decrementStat(.hunger)
            if self.dogVM.dog.foodStat < 0 {
                self.dogVM.dog.foodStat = 0
            }
            
            print("Pet's hunger decreased to \(self.dogVM.dog.foodStat)")
        }
    }
    
    private func fetchLocation(type: LocationType, lat: Float, lng: Float, radius: Int, completion: @escaping () -> Void) {
        print("Ini fetch \(type.rawValue)")
        let locationManager = LocationManager()
        locationManager.fetchLocation(lat: lat, lng: lng, radius: radius, type: type.rawValue) { [weak self] locations in
            DispatchQueue.main.async {
                switch type {
                case .clothingStore:
                    self?.clothingStoreLocations = locations
                case .hospital:
                    self?.hospitalLocations = locations
                case .aquarium, .bowlingAlley, .shoppingMall:
                    if let locations = locations {
                        if let existingLocations = self?.moodLocations {
                            self?.moodLocations = existingLocations + locations
                        } else {
                            self?.moodLocations = locations
                        }
                    }
                case .restaurant:
                    self?.restaurantLocations = locations
                case .mood:
                    return
                case .home:
                    return
                case .office:
                    return
                }
            }
            completion()
        }
    }
    
    func fetchAllLocations(lat: Float, lng: Float, radius: Int) {
        let group = DispatchGroup()
        
        group.enter()
        fetchLocation(type: .restaurant, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.enter()
        fetchLocation(type: .clothingStore, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.enter()
        fetchLocation(type: .hospital, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.enter()
        fetchLocation(type: .aquarium, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.enter()
        fetchLocation(type: .bowlingAlley, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.enter()
        fetchLocation(type: .shoppingMall, lat: lat, lng: lng, radius: radius) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.dataFetched = true
        }
    }
}

extension ContentViewModel {
    func checkNearbyRestaurants() {
        guard let userLocation = userLocation else { return }
        
        for restaurantLocation in restaurantLocations ?? [] {
            let restaurantCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(restaurantLocation.latitude), longitude: CLLocationDegrees(restaurantLocation.longitude))
            
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let restaurantCLLocation = CLLocation(latitude: restaurantCoordinate.latitude, longitude: restaurantCoordinate.longitude)
            
            let distance = userCLLocation.distance(from: restaurantCLLocation)
            
            if distance <= threshold {
                isNearRestaurant = true
                break // Keluar dari loop setelah menemukan restoran terdekat
            }
            
            isNearRestaurant = false
        }
    }
    func checkNearbyHospital() {
        guard let userLocation = userLocation else { return }
        
        for hospitalLocation in hospitalLocations ?? [] {
            let hospitalCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(hospitalLocation.latitude), longitude: CLLocationDegrees(hospitalLocation.longitude))
            
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let hospitalCLLocation = CLLocation(latitude: hospitalCoordinate.latitude, longitude: hospitalCoordinate.longitude)
            
            let distance = userCLLocation.distance(from: hospitalCLLocation)
            
            if distance <= threshold {
                isNearHospital = true
                break // Keluar dari loop setelah menemukan restoran terdekat
            }
            
            isNearHospital = false
        }
    }
    func checkNearbyStore() {
        guard let userLocation = userLocation else { return }
        
        for storeLocation in clothingStoreLocations ?? [] {
            let storeCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(storeLocation.latitude), longitude: CLLocationDegrees(storeLocation.longitude))
            
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let storeCLLocation = CLLocation(latitude: storeCoordinate.latitude, longitude: storeCoordinate.longitude)
            
            let distance = userCLLocation.distance(from: storeCLLocation)
            
            if distance <= threshold {
                isNearStore = true
                break // Keluar dari loop setelah menemukan restoran terdekat
            }
            
            isNearStore = false
        }
    }
    func checkNearbyPlayground() {
        guard let userLocation = userLocation else { return }
        
        for moodLocation in moodLocations ?? [] {
            let moodCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(moodLocation.latitude), longitude: CLLocationDegrees(moodLocation.longitude))
            
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let moodCLLocation = CLLocation(latitude: moodCoordinate.latitude, longitude: moodCoordinate.longitude)
            
            let distance = userCLLocation.distance(from: moodCLLocation)
            
            if distance <= threshold {
                isNearPlayground = true
                break // Keluar dari loop setelah menemukan restoran terdekat
            }
            
            isNearPlayground = false
        }
    }
    
}



