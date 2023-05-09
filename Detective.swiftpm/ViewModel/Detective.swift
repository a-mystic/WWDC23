//
//  File.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

final class Detective: ObservableObject {
    @Published private var detective = DetectiveBrain()
    
    var currentImage: UIImage? { detective.currentImage }
    var expressions: [String:Int] { detective.expressions }
    var images: [UIImage] { detective.images }
    var clickedButtons: Set<String> { detective.clickedButtons }
    
    func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.detective.setImage(image)
        }
    }
    
    func setExpressions(_ expression: String) {
        detective.setExpressions(expression)
    }
    
    func resetExpressions() {
        detective.resetExpressions()
    }
    
    func addImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.detective.addImage(image)
        }
    }
    
    func addButton(_ name: String) {
        detective.addButton(name)
    }
    
    func removeButton(_ name: String) {
        detective.removeButton(name)
    }
    
    func resetButtons() {
        detective.resetButtons()
    }
    
    // MARK: - Image Analyze Status
    
    @Published var imageAnalyzingStatus = ImageAnalyzingStatus.idle
    
    enum ImageAnalyzingStatus {
        case analyzing
        case idle
    }
    
    // MARK: - Video Errors
    @Published var VideoErrorStatus = VideoErrors.DeviceError
    @Published var showVideoError = false
    
    enum VideoErrors: Error {
        case DeviceError
        case ARKitError
        case RequestError
        
        var errorMessage: String {
            switch self {
            case .DeviceError: return "video device not detected."
            case .ARKitError: return "ARKit is not supported on this device."
            case .RequestError: return "no video requested."
            }
        }
    }
    
    // MARK: - Image Errors
    @Published var ImageErrorStatus = ImageErrors.noneImage
    @Published var showImageError = false
    
    enum ImageErrors: Error {
        case noneImage
        case convert
        case noneText
        
        var errorMessage: String {
            switch self {
            case .noneImage: return "no image Please capture an image."
            case .convert: return "image could not be converted. please use a different image."
            case .noneText: return "no texts in this image."
            }
        }
    }
}
