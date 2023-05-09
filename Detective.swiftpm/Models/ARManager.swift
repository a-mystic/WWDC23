//
//  File 2.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import RealityKit
import SwiftUI
import ARKit

struct ARManager {
    static var arView: ARView!
    static var materialColor = UIColor.black
    static var targetImage: UIImage?
    static var ImageReferenceSet = Set<ARReferenceImage>()
    static var mode: arViewMode = .idle
    
    enum arViewMode {
        case idle
        case imageDetection
        case game
    }
}
