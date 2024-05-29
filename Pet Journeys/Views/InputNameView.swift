//
//  InputNameView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 26/05/24.
//

import SwiftUI

let backgroundSolid = Color.accentColor

struct InputNameView: View {
    
    @State private var username: String = ""
    @State private var selectedYear: Int = 2003
    @State private var homeDone = false
    @State private var officeDone = false
    
    @StateObject var viewModel = InputNameViewModel()
    
    let years = Array(1924...2024)
    
    var body: some View {
        NavigationView{
            ZStack{
                backgroundSolid
                    .ignoresSafeArea()
                Image("pawprint")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 20) {
                    Image("miniLogo")
                        .padding(.top, 35)
                    
                    Spacer().frame(height: 120)
                    
                    StrokeText(text: "What's your name ?", width: 4, color: colorFromHex("5F1F10"))
                        .foregroundColor( colorFromHex("FFF0EC"))
                        .font(.custom("Boogaloo-Regular", size: 77))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorFromHex("5F1F10"), lineWidth: 10)
                            .frame(width: 404, height: 72) // Adjust the height as needed
                        
                        TextField("Your username", text: $username)
                            .font(.custom("Boogaloo-Regular", size: 30)) // Increase the font size here
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(width: 400, height: 60) // Adjust the height as needed
                            .offset(x: 0, y: 0)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    StrokeText(text: "When were you born ?", width: 4, color: colorFromHex("5F1F10"))
                        .foregroundColor( colorFromHex("FFF0EC"))
                        .font(.custom("Boogaloo-Regular", size: 77))
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorFromHex("5F1F10")
                                    , lineWidth: 10)
                            .frame(width: 422, height: 154) // Adjust the height as needed
                        
                        Picker("Year", selection: $selectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text(String(year))
                                    .font(.custom("Boogaloo-Regular", size: 30))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                        .frame(width: 500, height: 150)
                    }
                    
                    Spacer().frame(height: 110)
                    
                    Button(action: {
                        print(viewModel.shouldNavigateToNextPage)
                        viewModel.shouldNavigateToNextPage = true
                        print(viewModel.shouldNavigateToNextPage)
                    }) {
                        Text("Confirm")
                            .font(.custom("Boogaloo-Regular", size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 350)
                            .background(Image("buttonYellow"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 272)
                    .disabled(username.isEmpty)
                    
                    NavigationLink(
                        destination: IntroView(userName: $username, year: $selectedYear, homeDone: $homeDone, officeDone: $officeDone),
                        isActive: $viewModel.shouldNavigateToNextPage,
                        label: {
                            EmptyView()
                        })
                    .hidden()
                    
                    //        .navigationDestination(isPresented: $viewModel.shouldNavigateToNextPage) {
                    //            TestView()
                    //        }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color
    
    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

func colorFromHex(_ hex: String) -> Color {
    var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    if hex.count == 6 {
        hex = "FF\(hex)"
    }
    
    guard let int = UInt64(hex, radix: 16) else {
        return Color.black // Return a default color if the hex conversion fails
    }
    
    let alpha, red, green, blue: UInt64
    alpha = (int >> 24) & 0xff
    red = (int >> 16) & 0xff
    green = (int >> 8) & 0xff
    blue = int & 0xff
    
    return Color(
        .sRGB,
        red: Double(red) / 255,
        green: Double(green) / 255,
        blue: Double(blue) / 255,
        opacity: Double(alpha) / 255
    )
}


#Preview {
    InputNameView()
}
