//
//  Pet.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 20/05/24.
//

import Foundation

class Pet: ObservableObject{
    var name: String
    let image: String
//    var foodStat: Int = 100
//    var healthStat: Int = 100
//    var moodStat: Int = 100
//    var happinessStat: Int = 100
    @Published var foodStat: Int = 50
    @Published var healthStat: Int = 50
    @Published var moodStat: Int = 50
    @Published var energyStat: Int = 50
    @Published var isChange: Bool = true
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
//    public func decHealth(){
//        self.healthStat -= 1
//        self.isChange.toggle()
//    }
}

//class Dog: Pet {
//    init(name: String) {
//        super.init(name: name, image: "dogImage")
//    }
//}
//
//class Cat: Pet {
//    init(name: String) {
//        super.init(name: name, image: "catImage")
//    }
//}

class DogVM: ObservableObject{
    @Published var dog: Pet = Pet(name: "Dog", image: "ss")
    @Published var isChange: Bool = true
   
    public func incrementStat(_ stat: DogStat) {
        switch stat {
        case .health:
            self.dog.healthStat += 1
        case .hunger:
            self.dog.foodStat += 1
        case .mood:
            self.dog.moodStat += 1
        case .energy:
            self.dog.energyStat += 1
        }
        isChange.toggle()
    }
    
    public func decrementStat(_ stat: DogStat) {
        switch stat {
        case .health:
            self.dog.healthStat -= 1
        case .hunger:
            self.dog.foodStat -= 1
        case .mood:
            self.dog.moodStat -= 1
        case .energy:
            self.dog.energyStat -= 1
        }
        isChange.toggle()
    }
}


enum DogStat {
    case health
    case hunger
    case mood
    case energy
}
