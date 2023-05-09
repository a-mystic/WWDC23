//
//  MiniTools.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

struct MiniTools: View {
    @Binding var showScaleSlider: Bool
    @Binding var showMiniTools: Bool
    @Binding var showColorPicker: Bool
    
    var captureCompletion: () -> ()
    private let buttons = ["camera", "magnifyingglass", "paintpalette", "viewfinder", "gamecontroller", "eraser"]
        
    var body: some View {
        ZStack(alignment: .topLeading) {
            toolsBackground
            VStack(alignment: .leading) {
                HStack {
                    Spacer().frame(width: 15)
                    MiniToolsClose
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(buttons, id: \.self) { miniToolsButton($0) }
                    }.padding()
                }
                Spacer().frame(height: 2)
            }.padding()
        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showPhoto) { Photo() }
        .fullScreenCover(isPresented: $showCamera) { Camera() }
        .alert("Do you want to replace the object with something else?", isPresented: $showImageAlert) {
            changeImage
            cancelTracking
            restartTracking
            cancel
        }
        .alert("FindObject.", isPresented: $showObjectPicker) {
            camera
            photo
            cancel
        } message: {
            Text("choose whether to use a photo or a camera to find an object.")
        }
    }
    
    //MARK: - Alert properties
    
    var changeImage: some View {
        Button {
            showObjectPicker = true
        } label: {
            Text("Change Image")
        }
    }
    
    var cancelTracking: some View {
        Button {
            ARManager.mode = .idle
            DetectiveViewController().Detection()
        } label: {
            Text("Cancel Tracking")
        }
    }
    
    var restartTracking: some View {
        Button {
            ARManager.mode = .imageDetection
            DetectiveViewController().Detection()
        } label: {
            Text("Restart Tracking")
        }
    }
    
    var cancel: some View {
        Button("Cancel", role: .cancel) { }
    }
    
    @State private var showCamera = false
    @State private var showPhoto = false
    
    var camera: some View {
        Button {
            showCamera = true
        } label: {
            Text("Camera")
        }
    }
    
    var photo: some View {
        Button {
            showPhoto = true
        } label: {
            Text("Photo")
        }
    }
    
    //MARK: - Minitools
    
    var toolsBackground: some View {
        ZStack {
            Rectangle().fill(.gray.gradient).cornerRadius(20).blur(radius: 20)
            Rectangle().fill(.black.gradient.opacity(0.5)).cornerRadius(20).blur(radius: 20)
        }
    }
    
    var MiniToolsClose: some View {
        Button {
            showScaleSlider = false
            showColorPicker = false
            if gameCreated {
                gameCreated = false
            }
            detective.resetButtons()
            showMiniTools = false
        } label: {
            Text("Close")
        }
    }
    
    @State private var showImageAlert = false
    @State private var gameCreated = false
    @State private var showObjectPicker = false
    
    @EnvironmentObject var detective: Detective
    
    func miniToolsButton(_ name: String) -> some View {
        Button {
            miniAction(name)
        } label: {
            Image(systemName: name)
                .foregroundColor(.black)
                .frame(width:60, height:60)
                .font(.title)
                .background(detective.clickedButtons.contains(name) ? .gray.opacity(0.75) :.white.opacity(0.75))
                .cornerRadius(30)
                .padding()
        }
    }
    
    private func miniAction(_ name: String) {
        if detective.clickedButtons.contains(name) {
            detective.removeButton(name)
        } else {
            detective.addButton(name)
        }
        if (name == "camera" || name == "viewfinder" || name == "eraser") && detective.clickedButtons.contains(name) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { detective.removeButton(name) }
        }
        switch name {
        case "camera": captureCompletion()
        case "paintpalette": showColorPicker.toggle()
        case "magnifyingglass": showScaleSlider.toggle()
        case "eraser":
            DetectiveViewController().erase()
            showScaleSlider = false
            showColorPicker = false
            if gameCreated {
                gameCreated = false
            }
            detective.resetButtons()
        case "viewfinder":
            if ARManager.targetImage == nil {
                showObjectPicker = true
            } else {
                showImageAlert = true
            }
        case "gamecontroller":
            gameCreated.toggle()
            if gameCreated {
                clone()
                ARManager.mode = .game
                DetectiveViewController().Detection()
            } else {
                if let mode = cloneMode {
                    ARManager.mode = mode
                }
                DetectiveViewController().erase()
                DetectiveViewController().Detection()
            }
        default: return
        }
    }
    
    @State private var cloneMode: ARManager.arViewMode?
    
    private func clone() {
        if ARManager.mode != .game {
            cloneMode = ARManager.mode
        }
    }
}
