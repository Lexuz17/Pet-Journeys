//
//  AnimalSceneKit.swift
//  Pet Journeys
//
//  Created by Jason Susanto on 24/05/24.
//

import SwiftUI
import SceneKit

struct AnimalSceneKit: UIViewRepresentable {
//    @Binding var scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        
        if let scene = SCNScene(named: "Toothless.scn") {
            view.scene = scene
        }
        
        // SCNView Properties
        view.backgroundColor = .clear
        view.isJitteringEnabled = true
        view.antialiasingMode = .multisampling4X
        
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
}

struct AnimalSceneKit_Previews: PreviewProvider {
    static var previews: some View {
//        let animalScene = SCNScene(named: "Toothless.scn") ?? SCNScene()
//        
//        AnimalSceneKit(scene: .constant(animalScene))
        AnimalSceneKit()
            .frame(width: 200, height: 200)
    }
}
