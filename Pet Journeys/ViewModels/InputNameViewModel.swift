//
//  InputNameViewModel.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 27/05/24.
//

import SwiftUI

class InputNameViewModel: ObservableObject {
    @Published var shouldNavigateToNextPage = false

    func navigateToNextPage() {
        shouldNavigateToNextPage = true
    }
}
