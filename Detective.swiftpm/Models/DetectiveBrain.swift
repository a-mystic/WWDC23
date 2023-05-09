//
//  File.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

struct DetectiveBrain {
    private(set) var currentImage: UIImage?
    private(set) var expressions: [String:Int] = ["😁" : 0, "🙂" : 0, "😡" : 0, "😠" : 0, "😛" : 0, "😮" : 0]
    private(set) var images = [UIImage]()
    private(set) var clickedButtons = Set<String>()
    
    mutating func addImage(_ image: UIImage) {
        if images.count > 4 {
            images.remove(at: 0)
        }
        self.images.append(image)
    }
    
    mutating func setImage(_ image: UIImage?) {
        self.currentImage = image
    }
    
    mutating func setExpressions(_ expression: String) {
        if expressions.keys.contains(expression) {
            expressions[expression]! += 1
        }
    }
    
    mutating func resetExpressions() {
        expressions.keys.forEach { key in
            expressions[key] = 0
        }
    }
    
    mutating func addButton(_ name: String) {
        clickedButtons.insert(name)
    }
    
    mutating func removeButton(_ name: String) {
        clickedButtons.remove(name)
    }
    
    mutating func resetButtons() {
        clickedButtons = Set<String>()
    }
}
