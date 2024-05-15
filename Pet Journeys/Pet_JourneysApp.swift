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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
