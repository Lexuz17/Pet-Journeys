//
//  ChoosePetView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 30/05/24.
//

import SwiftUI

struct ChoosePetView: View {
    
    @State private var petName: String = ""
    @State private var isReadyToNextPage = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                backgroundSolid
                    .ignoresSafeArea()
                Image("pawprint")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 20) {
                    Image("miniLogo")
                        .padding(.top, 35)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorFromHex("5F1F10"), lineWidth: 10)
                            .frame(width: 404, height: 72) // Adjust the height as needed
                        
                        TextField("Choose a name", text: $petName)
                            .font(.custom("Boogaloo-Regular", size: 30)) // Increase the font size here
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(width: 400, height: 60) // Adjust the height as needed
                            .offset(x: 0, y: 0)
                    }
                    
                    Spacer().frame(height: 45)
                    
                    AnimalSceneKit()
                        .frame(width: 400)
                    
                    VStack (alignment: .center, spacing: 4){
                        StrokeText(text: "Choose Car or Dog", width: 4, color: colorFromHex("5F1F10"))
                            .foregroundColor( colorFromHex("FFF0EC"))
                            .font(.custom("Boogaloo-Regular", size: 77))
                        Text("(More pets coming soon!)")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 30))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                    }) {
                        Text("Confirm")
                            .font(.custom("Boogaloo-Regular", size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 350)
                            .background(Image("buttonYellow"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea()
                
                
            }
        }
    }
}

#Preview {
    ChoosePetView()
}
