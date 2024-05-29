//
//  LocationSearchService.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 28/05/24.
//
import MapKit

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    var coordinate: CLLocationCoordinate2D?
}

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    
    var completions = [SearchCompletions]()
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }
    
    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { .init(title: $0.title, subTitle: $0.subtitle, coordinate: nil) }
        for (index, result) in completer.results.enumerated() {
            getCoordinate(for: result, index: index)
        }
    }
    
    private func getCoordinate(for completion: MKLocalSearchCompletion, index: Int) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self, let response = response, let mapItem = response.mapItems.first, error == nil else {
                return
            }
            
            let coordinate = mapItem.placemark.coordinate
            if self.completions.indices.contains(index) {
                self.completions[index].coordinate = coordinate
            }
        }
        
    }
}
