//
//  File 2.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import ARKit

protocol FaceAnchorDelegate: AnyObject {
    func update(expression: String)
}

final class FaceAnchor: NSObject {
    weak var delegate: FaceAnchorDelegate?
    
    private var expression = ""
    
    func analyze(faceAnchor: ARFaceAnchor) {
        mouth(faceAnchor)
        eyebrow(faceAnchor)
        tongue(faceAnchor)
        mouthAndeyes(faceAnchor)
    }
    
    private func mouth(_ faceAnchor: ARFaceAnchor) {
        let mouthSmileLeft = faceAnchor.blendShapes[.mouthSmileLeft] as? CGFloat ?? 0
        let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as? CGFloat ?? 0
        let smile = (mouthSmileLeft + mouthSmileRight) / 2
        DispatchQueue.main.async { [weak self] in
            self?.isSmile(value: smile)
        }
    }
    
    private func eyebrow(_ faceAnchor: ARFaceAnchor) {
        let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? CGFloat ?? 0
        let browDownRight = faceAnchor.blendShapes[.browDownRight] as? CGFloat ?? 0
        let fret = (browDownLeft + browDownRight) / 2
        DispatchQueue.main.async { [weak self] in
            self?.isFret(value: fret)
        }
    }
    
    private func tongue(_ faceAnchor: ARFaceAnchor) {
        let tongueOut = faceAnchor.blendShapes[.tongueOut] as? CGFloat ?? 0
            DispatchQueue.main.async { [weak self] in
                self?.isTongueOut(value: tongueOut)
        }
    }
    
    private func mouthAndeyes(_ faceAnchor: ARFaceAnchor) {
        let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? CGFloat ?? 0
        let jawOpen = faceAnchor.blendShapes[.jawOpen] as? CGFloat ?? 0
        let eyeWideLeft = faceAnchor.blendShapes[.eyeWideLeft] as? CGFloat ?? 0
        let eyeWideRight = faceAnchor.blendShapes[.eyeWideRight] as? CGFloat ?? 0
        let openValue = (mouthFunnel + jawOpen + eyeWideLeft + eyeWideRight) / 4
        DispatchQueue.main.async { [weak self] in
            self?.isSurprise(value: openValue)
        }
    }

    
    private func isSmile(value: CGFloat) {
        switch value {
        case 0.5..<1: expression = "😁"
        case 0.2..<0.5: expression = "🙂"
        default: expression = ""
        }
        delegate?.update(expression: expression)
    }
    
    private func isFret(value: CGFloat) {
        switch value {
        case 0.6..<1: expression = "😡"
        case 0.5..<0.6: expression = "😠"
        default: break
        }
        delegate?.update(expression: expression)
    }
    
    private func isTongueOut(value:  CGFloat) {
        switch value {
        case 0.1..<1: expression = "😛"
        default: break
        }
        delegate?.update(expression: expression)
    }
    
    private func isSurprise(value: CGFloat) {
        switch value {
        case 0.2..<1: expression = "😮"
        default: break
        }
        delegate?.update(expression: expression)
    }
}
