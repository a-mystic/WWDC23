import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var detective: Detective
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .bottom) {
                    detectiveView.scaleEffect(scale)
                    miniTools(size: geometry)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(blurView.opacity(blur ? 1 : 0))
        .blur(radius: isCaptured ? 20 : 0)
    }
    
    @State private var isCaptured = false
    @State private var showMiniTools = false
    
    var enterMiniTools: some View {
        Button {
            showMiniTools.toggle()
        } label: {
            Image(systemName: "arrow.down")
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .font(.title)
                .background(.black.opacity(0.75))
                .cornerRadius(30)
                .padding()
        }
    }
    
    @State private var scale: Double = 1
    @State private var showScaleSlider = false
    
    func scaleSlider(size geometry: GeometryProxy) -> some View {
        SliderBar("Magnify", size: geometry.size.width/2, bounds: 1...3, value: $scale)
    }
        
    var detectiveView: some View {
        DetectiveView()
            .edgesIgnoringSafeArea(.all)
            .fullScreenCover(isPresented: $showLab) { Lab() }
            .sheet(isPresented: $showDescribe) { DescriptionView() }
            .alert("Cannot capture. Please set the magnify slider to 0.", isPresented: $captureScaleAlert) { okayButton }
            .alert("Cannot capture. Please set orientation to portrait", isPresented: $captureOrientationAlert) { okayButton }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { lab }
                ToolbarItem(placement: .navigationBarTrailing) { description }
            }
    }
    
    @State private var showColorPicker = false
    
    func miniTools(size geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            if showScaleSlider {
                scaleSlider(size: geometry)
            }
            if showColorPicker {
                colorPicker
            }
            if showMiniTools {
                MiniTools(
                    showScaleSlider: $showScaleSlider,
                    showMiniTools: $showMiniTools,
                    showColorPicker: $showColorPicker,
                    captureCompletion: capture
                )
                .frame(width: geometry.size.width, height: geometry.size.height/6)
                .frame(maxWidth: .infinity)
            } else {
                enterMiniTools
                Spacer().frame(height: 20)
            }
        }.frame(alignment: .bottom)
    }
    
    @State private var color = Color.black
    
    var colorPicker: some View {
        ColorPicker("Set Color", selection: $color)
            .onChange(of: color) { ARManager.materialColor = UIColor($0) }
            .padding()
            .background(color.opacity(0.3))
            .cornerRadius(14)
    }
    
    private var blur: Bool { showDescribe || showLab }
    
    @State private var showLab = false
    
    var lab: some View {
        Button {
            showLab.toggle()
        } label: {
            Image(systemName: "hammer.circle").font(.largeTitle).foregroundColor(.brown.opacity(0.9))
        }
    }
    
    @State private var showDescribe = false
    
    var description: some View {
        Button {
            showDescribe.toggle()
        } label: {
            Image(systemName: "questionmark.circle").font(.largeTitle).foregroundColor(.brown.opacity(0.9))
        }
    }
    
    @State private var captureScaleAlert = false
    @State private var captureOrientationAlert = false
    
    private func capture() {
        if scale < 1.05 && UIDevice.current.orientation.isPortrait {
            isCaptured.toggle()
            ARManager.arView.snapshot(saveToHDR: true) { image in
                DispatchQueue.global(qos: .background).async {
                    if let data = image?.pngData(), let compressedImage = UIImage(data: data) {
                        detective.setImage(compressedImage)
                        detective.addImage(compressedImage)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isCaptured.toggle() }
        } else {
            if !UIDevice.current.orientation.isPortrait {
                 captureOrientationAlert = true
            }
            if scale > 1.05 {
                captureScaleAlert = true
            }
        }
    }
}
