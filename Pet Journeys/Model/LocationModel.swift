//
//  Location.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

import Foundation

struct LocationModel: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}
