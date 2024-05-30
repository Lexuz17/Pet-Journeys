//
//  Pet_JourneysApp.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 15/05/24.
//

import SwiftUI

@main
struct Pet_JourneysApp: App {
    let persistenceController = PersistenceController.shared
    let viewModel = MapPickerViewModel()
    @StateObject private var homeLocation = LocationModel(name: "House", latitude: 0.0, longitude: 0.0)
    @StateObject private var officeLocation = LocationModel(name: "Office", latitude: 0.0, longitude: 0.0)

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
//            IntroView(userName: .constant("Jason"), year: .constant(2003))
//            TestView()
            
//            InputNameView()
            ChoosePetView()
                .environmentObject(viewModel)
                .environmentObject(homeLocation)
                .environmentObject(officeLocation)

//            InputNameView()
        }
    }
}
