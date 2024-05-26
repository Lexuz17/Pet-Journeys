//
//  AppDelegate.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 19/05/24.
//

import Foundation
import GoogleMaps
import GooglePlaces

let APIKey = "AIzaSyAkwuLu0vWxfeoUUV-zoqQjKhvHKkqcdaI"

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey(APIKey)
        GMSPlacesClient.provideAPIKey(APIKey)
        return true
    }
}
