//
//  DescriptionView.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

struct DescriptionView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("App") { Text("this app is a detective app. You can become a detective using some of the tools in this app.") }
                Section("Lab") { ForEach(DescriptionConstants.Lab, id: \.self) { Text($0) } }
                Section("MiniTools") { ForEach(DescriptionConstants.MiniTools, id: \.self) { Text($0) } }
                Section("Detective Pencil") { Text("draw a mark on the plane with your finger.") }
            }
            .navigationTitle("Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Close() } }
            .fontWeight(.regular)
        }
    }
    
    private struct DescriptionConstants {
        static let Lab = [
            "Image: you can experiment with different options for captured images.",
            "Memo: you can easily organize your thoughts into hand-drawn memo.",
            "Facial Expression: detect suspect facial expressions.",
            "Expression Analysis: analyzes and displays detected facial expressions."
        ]
        
        static let MiniTools = [
            "Capture: capture current screen.",
            "Magnify: magnify current screen.",
            "Palette: change the color of detective pencil.",
            "FindObject: find objects with your photos.",
            "CreateGame: you can play a mini guessing game on a plane."
        ]
    }
}
