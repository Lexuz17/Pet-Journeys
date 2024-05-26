//
//  LocationData.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

import Foundation

struct LocationData: Codable{
    let results: [Result]
}

struct Result: Codable{
    let name: String
    let user_ratings_total: Int?
    let geometry: Geometry
}

struct Geometry: Codable{
    let location: Location
}

struct Location: Codable{
    let lat: Double
    let lng: Double
}


