//
//  LocationManager.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

import Foundation

enum LocationType: String {
    case restaurant = "restaurant"
    case clothingStore = "clothing_store"
    case hospital = "hospital"
    case aquarium = "aquarium"
    case bowlingAlley = "bowling_alley"
    case shoppingMall = "shopping_mall"
    case mood = "mood"
    case home = "home"
    case office = "office"
}

struct LocationManager {
    let gmapsURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    let apiKey = "AIzaSyAkwuLu0vWxfeoUUV-zoqQjKhvHKkqcdaI"
    
    func fetchLocation(lat: Float, lng: Float, radius: Int, type: LocationType.RawValue, completion: @escaping ([LocationModel]?) -> Void) {
        let urlString = "\(gmapsURL)?location=\(lat),\(lng)&radius=\(radius)&type=\(type)&key=\(apiKey)"
        performRequest(with: urlString, completion: completion)
    }
    
    func performRequest(with urlString: String, completion: @escaping ([LocationModel]?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Perform request Error: \(error)")
                    completion(nil)
                    return
                }
                if let safeData = data {
                    if let locations = self.parseJSON(safeData) {
                        completion(locations)
                    } else {
                        completion(nil)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ locationData: Data) -> [LocationModel]? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(LocationData.self, from: locationData)
            let locations = decodedData.results.compactMap { result in
                
                if let userRatingsTotal = result.user_ratings_total, userRatingsTotal >= 50 {
                    return LocationModel(
                        name: result.name,
                        latitude: result.geometry.location.lat,
                        longitude: result.geometry.location.lng
                    )
                } else {
                    return nil
                }
            }
            return locations
        } catch {
            print("Error decoding data: \(error)")
            return nil
        }
    }
}
