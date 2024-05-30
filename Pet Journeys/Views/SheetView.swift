//
//  SheetView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 28/05/24.
//

import SwiftUI
import MapKit

struct SheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: MapPickerViewModel
    @State private var searchService = LocationSearchService(completer: .init())
    @State private var search: String = ""
    @State private var isError = false
    var locationType: String
    var onCoordinateSelect: ((CLLocationCoordinate2D) -> Void)?
    
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "magnifyingglass")
                TextField("Search Place", text: $search)
                    .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            Spacer()
            
            List {
                ForEach(searchService.completions) { completion in
                    Button(action: {
                        print(completion)
                        if let coordinate = completion.coordinate {
                            viewModel.markCoordinate(to: coordinate, type: locationType)
                            onCoordinateSelect?(coordinate)
                            presentationMode.wrappedValue.dismiss()
                            isError = false
                        } else {
                            isError = true
                            print("Error: Coordinate is nil")
                            
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(completion.subTitle)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            if(isError){
                Text("Try another place, the place doesn't have a registered location..")
                    .font(.callout)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back")
                    .frame(width: 130, height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .fontWeight(.bold)
            }
        }
        .onChange(of: search) {
            searchService.update(queryFragment: search)
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }
    
    
    struct TextFieldGrayBackgroundColor: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(12)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}
