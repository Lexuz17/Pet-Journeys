//
//  IntroView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 27/05/24.
//

import SwiftUI

struct IntroView: View {
    @Binding var userName: String
    @Binding var year: Int
    @Binding var homeDone: Bool
    @Binding var officeDone: Bool
    
    @State private var isActionCompleted = false
    @StateObject var viewModel = IntroViewModel()
    
    var body: some View {
        NavigationView{
            ZStack{
                backgroundSolid
                    .ignoresSafeArea()
                Image("pawprint")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)
                
                VStack{
                    Image("miniLogo")
                        .padding(.top, 35)
                    
                    Spacer().frame(height: 7)
                    
                    ZStack{
                        Image("infoBg")
                            .shadow(color: .white, radius: 8)
                        
//                        ada beberapa view yang bisa dibuat reusable
                        VStack{
                            Text("Welcome \(userName.capitalized), We’re so glad you’re here.")
                                .font(.custom("Boogaloo", size: 60))
                                .frame(width: 650)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 45)
                                .foregroundColor(colorFromHex("3B0C01"))
                            
                            Text("In Pet Journey, your virtual pet’s adventures are shaped by real-world locations.")
                                .font(.custom("Boogaloo", size: 36))
                                .frame(width: 680)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 20)
                                .foregroundColor(colorFromHex("774134"))
                            
                            Text("To get started, please set your home and office locations using the buttons below. This will help us create a personalized and engaging experience for both you and your pet.")
                                .font(.custom("Boogaloo", size: 36))
                                .frame(width: 680)
                                .multilineTextAlignment(.center)
                                .foregroundColor(colorFromHex("774134"))
                        }
                    }
                    
                    Spacer().frame(height: 30)
                    
                    HStack{
                        Button(action: {
                            viewModel.navigateToSetHome()
                        }, label: {
                            Text("")
                                .background(Image("HomeButton"))
                                .frame(width: 410, height: 285)
                        })
                        
                        Spacer().frame(width: 48)
                        
                        if year <= 2003 {
                            Button(action: {
                                viewModel.navigateToSetOffice()
                            }) {
                                Text("")
                                    .background(Image("OfficeButton"))
                                    .frame(width: 410, height: 285)
                            }
                        } else {
                            Button(action: {
                                // Action for School button
                            }) {
                                Text("")
                                    .background(Image("SchoolButton"))
                                    .frame(width: 410, height: 285)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 63)
                    
                    Button(action: {
                        print(viewModel.shouldNavigateToNextPage)
                        viewModel.navigateToNextPage()
                        print(viewModel.shouldNavigateToNextPage)
                    }) {
                        Text("Continue")
                            .font(.custom("Boogaloo-Regular", size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 350)
                            .background(Image("buttonYellow"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 91)
                    .disabled(!(homeDone && officeDone))
                    
                    NavigationLink(
                        destination: locationPicker(userName: $userName, year: $year, homeDone: $homeDone, officeDone: $officeDone, isHomeLocation: true),
                        isActive: $viewModel.shouldNavigateToHome,
                        label: {
                            EmptyView()
                        })
                    .hidden()
                    
                    NavigationLink(
                        destination: locationPicker(userName: $userName, year: $year, homeDone: $homeDone, officeDone: $officeDone, isHomeLocation: false),
                        isActive: $viewModel.shouldNavigateToOffice,
                        label: {
                            EmptyView()
                        })
                    .hidden()
                    
                    NavigationLink(
                        destination: ContentView(),
                        isActive: $viewModel.shouldNavigateToNextPage,
                        label: {
                            EmptyView()
                        })
                    .hidden()
                    
    //                NavigationLink(destination: LocationPickerOffice(), isActive: $viewModel.shouldNavigateToOffice) {
    //                    EmptyView()
    //                }
    //                .hidden()
    //
    //                NavigationLink(destination: LocationPickerSchool(), isActive: $viewModel.shouldNavigateToSchool) {
    //                    EmptyView()
    //                }
    //                .hidden()
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    IntroView(userName: .constant("Jason"), year: .constant(2003))
//}
