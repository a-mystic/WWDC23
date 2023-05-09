//
//  UtilityExtensions.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

extension CGSize {
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

extension SIMD3<Float> {
    static func *(lhs: Self, rhs: CGFloat) -> SIMD3<Float> {
        SIMD3<Float>(x: lhs.x * Float(rhs), y: lhs.y * Float(rhs), z: lhs.z * Float(rhs))
    }
}

extension View {
    @ViewBuilder
    func magnify(_ scale: CGFloat, visiable: Bool) -> some View {
        if visiable {
            Magnifier(scale: scale) { self }
        } else {
            self
        }
    }
    func reverseMask<Content: View> (@ViewBuilder content: @escaping () -> Content) -> some View {
        self.mask { Rectangle().overlay { content().blendMode(.destinationOut) } }
    }
}
