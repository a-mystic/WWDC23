//
//  MemoView.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI
import PencilKit

struct MemoView: View {
    @EnvironmentObject var detective: Detective

    private let canvasView = PKCanvasView()
    
    var body: some View {
        Drawing(canvasView).toolbar { ToolbarItem(placement: .navigationBarTrailing) { eraser } }
    }
    
    var eraser: some View {
        Button {
            canvasView.drawing = PKDrawing()
        } label: {
            Image(systemName: "eraser").font(.title)
        }
    }
}
