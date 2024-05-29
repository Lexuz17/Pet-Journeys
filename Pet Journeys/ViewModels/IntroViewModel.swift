//
//  IntroViewModel.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 27/05/24.
//

import Foundation

class IntroViewModel: ObservableObject {
    @Published var shouldNavigateToHome = false
    @Published var shouldNavigateToOffice = false
    @Published var shouldNavigateToSchool = false
    @Published var shouldNavigateToNextPage = false
    
    func navigateToNextPage() {
        shouldNavigateToNextPage = true
    }
    
    func navigateToSetHome() {
        shouldNavigateToHome = true
    }
}
