//
//  TestView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

import SwiftUI
import MapKit

struct TestView: View {
    
    @EnvironmentObject var viewModel: MapPickerViewModel
    @State var shouldPresentSheet = false
    
    var body: some View {
//        VStack{
            VStack{
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search Place")
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity) // Set lebar HStack menjadi penuh
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .contentShape(Rectangle())
                .onTapGesture {
                    shouldPresentSheet.toggle()
                }
                
                .sheet(isPresented: $shouldPresentSheet) {
                    print("Sheet dismissed!")
                } content: {
                    SheetView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                
                MapPickerView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(width: 740, height: 700)
//        }
        
        
        //#Preview {
        //    TestView()
        //}
    }
}
