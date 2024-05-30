//
//  CustomMapPickerView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 28/05/24.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    
    @ObservedObject var viewModel: MapPickerViewModel
    let initialDistance = 500.0
    let initialHeading = 0.0
    let initialPitch = 0.0
    
    var locationType: String
    
    var body: some View {
        MapReader { mapProxy in
            Map(position: $viewModel.mapCameraPosition, selection: $viewModel.selectedMapItem) {
                UserAnnotation()
                
                // if the user has tapped on the map, show the location of the tap
                if let coordinate = viewModel.getTappedCoordinate(type: locationType) {
                    Marker("", systemImage: locationType == "home" ? "house.fill" : "briefcase.fill", coordinate: coordinate)
                        .tint(.red)
                }
            }
            .mapStyle(
                viewModel.mapType == .standard ? .standard(elevation: .realistic, pointsOfInterest: .all) : .hybrid(elevation: .realistic, pointsOfInterest: .all)
            )
            .onAppear {
                if let currentLocation = viewModel.userLocation {
                    viewModel.mapCameraPosition = .camera(MapCamera(centerCoordinate: currentLocation, distance: initialDistance, heading: initialHeading, pitch: initialPitch))
                }
            }
            .onTapGesture(coordinateSpace: .local) { location in
                if let coordinate: CLLocationCoordinate2D = mapProxy.convert(location, from: .local) {
                    viewModel.markCoordinate(to: coordinate, type: locationType)
                }
            }
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.centerMapOnUserLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    Spacer()
                }
            )
        }
    }
}

//#Preview {
//    CustomMapPickerView()
//}


//#Preview {
//    CustomMapPickerView()
//}
