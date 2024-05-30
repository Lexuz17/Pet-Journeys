//
//  LocationPickerHome.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 27/05/24.
//

import SwiftUI
import MapKit

struct locationPicker: View {
    
    @EnvironmentObject var viewModel: MapPickerViewModel
    @EnvironmentObject var homeLocation: LocationModel
    @EnvironmentObject var officeLocation: LocationModel
    
    @State var shouldPresentSheet = false
    @State var coordinate: CLLocationCoordinate2D? = nil
    @State var isDone: Bool = false
    @State var shouldNavigateToNextPage = false
    
    @Binding var userName: String
    @Binding var year: Int
    @Binding var homeDone: Bool
    @Binding var officeDone: Bool
    
    var isHomeLocation: Bool
    
    var body: some View {
        NavigationView {
            ZStack{
                backgroundSolid
                    .ignoresSafeArea()
                Image("pawprint")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.7)
                
                VStack{
                    Image("miniLogo")
                        .padding(.top, 35)

                    Spacer()
                    
                    StrokeText(text: "Set Home Location", width: 4, color: colorFromHex("5F1F10"))
                        .foregroundColor( colorFromHex("FFF0EC"))
                        .font(.custom("Boogaloo-Regular", size: 77))
                    
                    Spacer().frame(height: 28)
                    showMapPicker()
                    Spacer()
                    
                    Button(action: {
                        let locationType = isHomeLocation ? "home" : "office"
                        if let newCoordinate = viewModel.getTappedCoordinate(type: locationType) {
                            print(newCoordinate)
                            if isHomeLocation {
                                homeLocation.latitude = newCoordinate.latitude
                                homeLocation.longitude = newCoordinate.longitude
                                homeDone = true
                            } else {
                                officeLocation.latitude = newCoordinate.latitude
                                officeLocation.longitude = newCoordinate.longitude
                                officeDone = true
                            }
                            shouldNavigateToNextPage = true
                        }
                    }) {
                        Text("Confirm")
                            .font(.custom("Boogaloo-Regular", size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 350)
                            .background(Image("buttonYellow"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 96)
                    .disabled(viewModel.getTappedCoordinate(type: isHomeLocation ? "home" : "office") == nil)

                    NavigationLink(
                        destination: IntroView(userName: $userName, year: $year, homeDone: $homeDone, officeDone: $officeDone),
                        isActive: $shouldNavigateToNextPage,
                        label: {
                            EmptyView()
                        })
                    .hidden()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
    fileprivate func showMapPicker() -> some View {
        VStack{
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search Place")
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity) // Set lebar HStack menjadi penuh
            .background(Color.white)
            .foregroundColor(.primary)
            .cornerRadius(8)
            .contentShape(Rectangle())
            .onTapGesture {
                shouldPresentSheet.toggle()
            }
            
            .sheet(isPresented: $shouldPresentSheet) {
                print("Sheet dismissed!")
            } content: {
                SheetView(locationType: isHomeLocation ? "home" : "office")
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            
            MapPickerView(viewModel: viewModel, locationType: isHomeLocation ? "home" : "office")
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: 740, height: 680)
    }
}
//#Preview {
//    LocationPickerHome()
//}