//
//  Location.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

//import Foundation
//
//struct LocationModel: Identifiable, Hashable {
//    var id = UUID()
//    let name: String
//    let latitude: Double
//    let longitude: Double
//}


import Foundation
import Combine

class LocationModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var name: String
    @Published var latitude: Double
    @Published var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
