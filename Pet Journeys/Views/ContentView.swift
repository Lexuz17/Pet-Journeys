//
//  ContentView.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 15/05/24.
//x

import SwiftUI
import CoreData
import MapKit


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // MARK: - Location
    //    @StateObject var viewModel = ContentViewModel()
    //    @State private var mapView = MKMapView() // Create a new MKMapView instance
    
    @StateObject var dogVM = DogVM()
    @StateObject var viewModel: ContentViewModel
    @StateObject var locationService: LocationService

    init() {
        let locationService = LocationService()
        let dogVM = DogVM()
        _dogVM = StateObject(wrappedValue: dogVM)
        _viewModel = StateObject(wrappedValue: ContentViewModel(dogVM: dogVM))
        _locationService = StateObject(wrappedValue: locationService)
    }
//    init() {
//        let initialPet = Dog(name: "Winter")
//        _viewModel = StateObject(wrappedValue: ContentViewModel(pet: initialPet))
//    }
    
    @State private var offset: CGSize = .zero
        
    var body: some View {
        ZStack{
            ZStack {
                if viewModel.dataFetched {
                    CustomMapView(mapRegion: $viewModel.mapRegion, viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                }
                else {
                    ProgressView("Loading Map..")
                }
                VStack{
                    MenuRectangle(healthStat: self.dogVM.dog.healthStat, moodStat: self.dogVM.dog.moodStat, hungerStat: self.dogVM.dog.foodStat, energyStat: self.dogVM.dog.energyStat, isNearRestaurant: $viewModel.isNearRestaurant)
                    HStack {
                        VStack(alignment: .leading) {
                            IconStackRectangle(imageName: "Bagpack", size: CGSize(width: 100, height: 100), cornerRadius: 18)
                            Spacer()
                            IconStackCircle(imageName: "Monkey", size: CGSize(width: 144, height: 144))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            IconStackRectangle(imageName: "Location", size: CGSize(width: 100, height: 100), cornerRadius: 18)
                            Spacer()
                            if viewModel.isNearStore{
                                IconStackCircle(imageName: "Store", size: CGSize(width: 285, height: 285))
                            }
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 60)
                    .padding([.leading, .trailing], 30)
                }
            }
            .ignoresSafeArea(.all)
            
//            AnimalSceneKit()
//                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
        }
        
//        VStack {
//            Button(action: {
//                self.viewModel.pet?.decHealth()
//            }) {
//                Text("Decrease")
//            }
//            Text("\(self.viewModel.pet?.healthStat ?? 0)")
//        }
//        .onChange(of: self.viewModel.pet?.healthStat, { oldValue, newValue in
//            print("Health stat changed to \(newValue ?? 0)")
//        })
//        .ignoresSafeArea(.all)
    }
    
    var joystick: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                    //                                    updateLocation()
                                    print("height: \(offset.height)")
                                    print("width: \(offset.width)")
                                }
                                .onEnded { _ in
                                    offset = .zero
                                }
                        )
                )
        }
        .frame(width: 100, height: 100)
    }
    
}

struct MenuRectangle: View {
    var healthStat: Int
    var moodStat: Int
    var hungerStat: Int
    var energyStat: Int
    @Binding var isNearRestaurant: Bool

    var body: some View {
        ZStack {
            BlurView(style: .systemMaterial)
                .opacity(0.4)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "98DCFE"), Color(hex: "5692B1")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 160)
                .opacity(0.6)
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "001D56"))
                        .frame(height: 5)
                        .opacity(0.4),
                    alignment: .bottom
                )
            
            HStack{
                Image("Coin")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .shadow(radius: 10)
                
                Spacer()
                
                HStack{
                    VStack{
                        ZStack(alignment: .center){
                            Image("Burger-bg")
                                .resizable()
                                .frame(width: 110, height: 110)
                            
                            Image("Burger-real")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Rectangle().offset(y: 100 - CGFloat(hungerStat)))
                        }
                        .shadow(radius: 8)
                        
                        if isNearRestaurant {
                            Text("🔥")
                                .font(.largeTitle)
                                .transition(.opacity)
                        }
                    }
                    
                    ZStack(alignment: .center) {
                        Image("Heart-bg")
                            .resizable()
                            .frame(width: 110, height: 110)
                        Image("Heart-real")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Rectangle().offset(y: 100 - CGFloat(healthStat)))
                    }
                    .shadow(radius: 8)
                    
                    ZStack(alignment: .center) {
                        Image("Happy-bg")
                            .resizable()
                            .frame(width: 110, height: 110)
                        Image("Happy-real")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Rectangle().offset(y: 100 - CGFloat(moodStat)))
                    }
                    .shadow(radius: 8)
                    
                    ZStack(alignment: .center) {
                        Image("Mood-bg")
                            .resizable()
                            .frame(width: 110, height: 110)
                        Image("Moods-real")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Rectangle().offset(y: 100 - CGFloat(energyStat)))
                    }
                    .shadow(radius: 8)
                }
                
                Spacer()
                
                Image("Animal")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .shadow(radius: 8)
            }
            .padding(.horizontal, 30)
        }
        .frame(height: 160)
        .clipShape(Rectangle())
    }
}

struct IconStackCircle: View {
    var imageName: String
    var size: CGSize
    
    var body: some View {
        ZStack {
            BlurView(style: .systemMaterial)
                .opacity(0.5)
                .frame(width: size.width, height: size.height)
            
            Image(imageName)
                .resizable()
                .scaledToFill()
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
}

struct IconStackRectangle: View {
    var imageName: String
    var size: CGSize
    var cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            BlurView(style: .systemMaterial)
                .opacity(0.3)
                .frame(width: size.width, height: size.height)
            
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000ff) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
