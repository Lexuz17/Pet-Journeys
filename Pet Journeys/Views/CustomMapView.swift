//
//  CustomMapView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 17/05/24.
//

import SwiftUI
import MapKit
import SceneKit
//import GooglePlaces
//import GoogleMaps

struct CustomMapView: UIViewRepresentable {
    @Binding var mapRegion: MKCoordinateRegion
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var homeLocation: LocationModel
    
    func makeUIView(context: Context) -> MKMapView {
        let hour = Calendar.current.component(.hour, from: Date())
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.setRegion(mapRegion, animated: false)
        mapView.delegate = context.coordinator
        mapView.isPitchEnabled = false
        mapView.isScrollEnabled = false 
        mapView.pointOfInterestFilter = .excludingAll
        mapView.mapType = .mutedStandard
        mapView.isZoomEnabled = false
        mapView.showsCompass = false
        if hour < 17 {
            mapView.overrideUserInterfaceStyle = .light
        }
        else {
            mapView.overrideUserInterfaceStyle = ./*dark*/light
        }
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        mapView.addGestureRecognizer(panGesture)
        
        print("Start updating Heading")
        context.coordinator.startUpdatingHeading()
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
            if mapRegion.center.latitude != mapView.region.center.latitude ||
                mapRegion.center.longitude != mapView.region.center.longitude {
                mapView.setRegion(mapRegion, animated: true)
                let camera = MKMapCamera(
                    lookingAtCenter: mapRegion.center,
                    fromDistance: context.coordinator.currentAltitude,
                    pitch: context.coordinator.currentPitch,
                    heading: mapView.camera.heading
                )
                mapView.setCamera(camera, animated: true)
            }
            if viewModel.dataFetched {
                updateAnnotations(mapView: mapView)
            }
        }
    
    private func updateAnnotations(mapView: MKMapView) {
        // Update user location annotation
        if let userLocation = viewModel.userLocation {
            if let existingAnnotation = mapView.annotations.first(where: { $0 is UserLocationAnnotation }) as? UserLocationAnnotation {
                existingAnnotation.coordinate = userLocation
            } else {
                let userAnnotation = UserLocationAnnotation(coordinate: userLocation)
                mapView.addAnnotation(userAnnotation)
            }
        }
        
        // Update other locations annotations
        updateAnnotations(from: viewModel.restaurantLocations, to: mapView, type: LocationType.restaurant.rawValue)
        updateAnnotations(from: viewModel.clothingStoreLocations, to: mapView, type: LocationType.clothingStore.rawValue)
        updateAnnotations(from: viewModel.hospitalLocations, to: mapView, type: LocationType.hospital.rawValue)
        updateAnnotations(from: viewModel.moodLocations, to: mapView, type: LocationType.mood.rawValue)
        updateAnnotations(from: [homeLocation], to: mapView, type: LocationType.home.rawValue)
    }
    
    private func updateAnnotations(from locations: [LocationModel]?, to mapView: MKMapView, type: String) {
        guard let locations = locations else { return }
        
        let currentAnnotations = mapView.annotations.compactMap { $0 as? LocationAnnotation }
        let existingAnnotations = currentAnnotations.filter { $0.type == type }
        
        var toRemove = Set(existingAnnotations)
        var toAdd: [LocationAnnotation] = []
        
        for location in locations {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            if let existingAnnotation = existingAnnotations.first(where: { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) {
                toRemove.remove(existingAnnotation)
            } else {
                let annotation = LocationAnnotation(coordinate: coordinate, title: location.name, type: type)
                toAdd.append(annotation)
            }
        }
        
        mapView.removeAnnotations(Array(toRemove))
        mapView.addAnnotations(toAdd)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: CustomMapView
        private var locationManager: CLLocationManager
        var mapView: MKMapView?
        private var initialHeading: CLLocationDirection = 0
        var currentPitch: CGFloat = 70.0
        var currentAltitude: CLLocationDistance = 800.0
        var userLocationAnnotation: UserLocationAnnotation?

        init(_ parent: CustomMapView) {
            self.parent = parent
            self.locationManager = CLLocationManager()
            super.init()
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        func startUpdatingHeading() {
            print("start update heading")
            if CLLocationManager.headingAvailable() {
                locationManager.startUpdatingHeading()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            print("Update Heading \(newHeading.headingAccuracy)")
            if newHeading.headingAccuracy > 0 {
                updateCameraHeading(newHeading.trueHeading)
            }
        }
        
        private func updateCameraHeading(_ heading: CLLocationDirection) {
            guard let mapView = mapView else { return }
            let camera = MKMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: currentAltitude, pitch: currentPitch, heading: heading)
            mapView.setCamera(camera, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            mapView.annotations.forEach {
                if let annotation = $0 as? UserLocationAnnotation {
                    mapView.removeAnnotation(annotation)
                }
            }
            
            // Set camera to user location
            let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromDistance: currentAltitude, pitch: currentPitch, heading: mapView.camera.heading)
            mapView.setCamera(camera, animated: false)
            
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            if let userLocationAnnotation = annotation as? UserLocationAnnotation {
                return createUserLocationAnnotationView(for: userLocationAnnotation, on: mapView)
            } else if let locationAnnotation = annotation as? LocationAnnotation {
                return createLocationAnnotationView(for: locationAnnotation, on: mapView)
            }
            return nil
        }

        private func createUserLocationAnnotationView(for annotation: MKAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let identifier = "UserLocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                
                let hostingController = UIHostingController(rootView: AnyView(AnimalSceneKit()))
                hostingController.view.backgroundColor = .clear
                hostingController.view.frame = CGRect(x: -45, y: -90, width: 100, height: 100)
                
                annotationView?.addSubview(hostingController.view)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView!
        }
        
        private func createLocationAnnotationView(for annotation: MKAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                if let locationAnnotation = annotation as? LocationAnnotation {
                    let hostingController: UIHostingController<AnyView>

                    switch locationAnnotation.type {
                    case LocationType.restaurant.rawValue:
                        hostingController = UIHostingController(rootView: AnyView(RestoAnnotation()))
                    case LocationType.hospital.rawValue:
                        hostingController = UIHostingController(rootView: AnyView(HospitalAnnotation()))
                    case LocationType.clothingStore.rawValue:
                        hostingController = UIHostingController(rootView: AnyView(ShopAnnotation()))
                    case LocationType.mood.rawValue:
                        hostingController = UIHostingController(rootView: AnyView(MoodAnnotation()))
                    case LocationType.home.rawValue:
                        hostingController = UIHostingController(rootView: AnyView(HouseAnnotation()))                        
                    default:
                        hostingController = UIHostingController(rootView: AnyView(EmptyView()))
                    }
                    
                    hostingController.view.backgroundColor = .clear
                    hostingController.view.frame = CGRect(x: -20, y: -30, width: 50, height: 50)
                    
                    annotationView?.addSubview(hostingController.view)
                }
                
                annotationView?.rightCalloutAccessoryView = UIButton(type: .roundedRect)
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView!
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            searchRestaurants(in: mapView.region)
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            if gesture.state == .began {
                print("1")
                initialHeading = mapView.camera.heading
            } else if gesture.state == .changed {
                print("2")
                let translation = gesture.translation(in: mapView)
                let newHeading = initialHeading - CLLocationDirection(translation.x / 4)
                
                let camera = MKMapCamera(lookingAtCenter: mapView.userLocation.coordinate, fromDistance: currentAltitude, pitch: currentPitch, heading: newHeading)
                mapView.setCamera(camera, animated: false)
            
                // Perbarui posisi tampilan annotation
                for annotation in mapView.annotations {
                    if let locationAnnotation = annotation as? LocationAnnotation {
                        let point = mapView.convert(locationAnnotation.coordinate, toPointTo: mapView)
                        if let annotationView = mapView.view(for: locationAnnotation) {
                            annotationView.center = point
                            annotationView.setNeedsLayout() // Perbarui layout view
                        }
                    }
                }
            } else if gesture.state == .ended {
                print("3")
                initialHeading = mapView.camera.heading
            }
        }
        
//        func searchRestaurants(in region: MKCoordinateRegion) {
//            let northEast = CLLocationCoordinate2D(
//                latitude: region.center.latitude + region.span.latitudeDelta / 2,
//                longitude: region.center.longitude + region.span.longitudeDelta / 2
//            )
//            let southWest = CLLocationCoordinate2D(
//                latitude: region.center.latitude - region.span.latitudeDelta / 2,
//                longitude: region.center.longitude - region.span.longitudeDelta / 2
//            )
//            
//            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//            let filter = GMSAutocompleteFilter()
//            filter.type = .establishment // Filter for establishments (businesses)
//            
//            GMSPlacesClient.shared().findAutocompletePredictions(
//                fromQuery: "restaurant",
//                filter: filter,
//                sessionToken: nil
//            ) { (results, error) in
//                guard let results = results, error == nil else {
//                    print("Error: \(String(describing: error))")
//                    return
//                }
//                
//                for result in results {
//                    print("Restaurant: \(result.attributedFullText.string)")
//                }
//            }
//        }
        
    }
    
    class UserLocationAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D

        init(coordinate: CLLocationCoordinate2D) {
            self.coordinate = coordinate
        }
    }
    
    class LocationAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var type: String
        var currentPosition: CGPoint = .zero // Properti baru untuk menyimpan posisi tampilan saat ini

        init(coordinate: CLLocationCoordinate2D, title: String?, type: String) {
            self.coordinate = coordinate
            self.title = title
            self.type = type
        }
    }
    
    class AnimalAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var sceneName: String
        
        init(coordinate: CLLocationCoordinate2D, title: String?, sceneName: String) {
            self.coordinate = coordinate
            self.title = title
            self.sceneName = sceneName
        }
    }
}
