//
//  ImageView.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI
import Vision

struct ImageView: View {
    @EnvironmentObject var detective: Detective
    
    @State private var screenWidth: CGFloat = .zero
    @State private var screenHeight: CGFloat = .zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if let currentImage = self.detective.currentImage {
                    ZStack(alignment: .leading) {
                        imageBody(currentImage, geometry: geometry)
                        imageSlider(width: screenWidth/9, height: screenHeight/9)
                    }.clipped()
                } else {
                    Label("Please capture image.", systemImage: "photo")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .font(.title)
                }
            }
            Spacer().frame(height: 10)
            if detective.currentImage != nil {
                editImageConstructs
            }
        }
        .padding()
        .sheet(isPresented: $showAnalysis) {
            AnalyzedTextView(textFromImage)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                more.contextMenu {
                    magnify
                    analyze
                    grayScale
                    resetButton
                }
            }
        }
        .alert("Image Error", isPresented: $detective.showImageError) {
            
        } message: {
            Text(detective.ImageErrorStatus.errorMessage)
        }
        .alert("Analyze Error", isPresented: $analyzeError) {
            
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if detective.imageAnalyzingStatus == .analyzing {
                progress
            }
        }
    }
    
    @State private var cloneImage: UIImage?
    
    func imageBody(_ image: UIImage, geometry: GeometryProxy) -> some View {
        HStack {
            Spacer().frame(width: 14, height: 0)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: geometry.size.width, height: geometry.size.height)
                .magnify(scale, visiable: scaleable)
                .saturation(saturation)
                .brightness(brightness)
                .contrast(contrast)
                .rotationEffect(Angle(degrees: rotationDegrees))
                .onAppear {
                    screenWidth = geometry.frame(in: .local).size.width
                    screenHeight = geometry.frame(in: .local).size.height
                    cloneImage = detective.currentImage
                }
                .shadow(radius: 4)
                .padding(.horizontal)
        }
    }
    
    func imageSlider(width: CGFloat, height: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(detective.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: width, height: height)
                        .onTapGesture {
                            detective.setImage(image)
                            cloneImage = image
                            reset()
                        }
                }
            }
            .padding(.vertical, 10)
            .background(sliderBackground())
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    var linearRectangle: some View {
        Rectangle().background(LinearGradient(gradient: Gradient(colors: [.black]), startPoint: .top, endPoint: .bottom))
    }
    
    // MARK: - Context Menu
    
    var more: some View {
        Button {
            
        } label: {
            Image(systemName: "ellipsis.circle").font(.title)
        }
    }
    
    var magnify: some View {
        Button("magnify") {
            if detective.currentImage != nil {
                scaleable.toggle()
            } else {
                detective.ImageErrorStatus = .noneImage
                detective.showImageError = true
            }
        }
    }
    
    var analyze: some View {
        Button("get text") {
            if detective.currentImage != nil {
                detective.imageAnalyzingStatus = .analyzing
                getTextFromImage(detective.currentImage)
            } else {
                detective.ImageErrorStatus = .noneImage
                detective.showImageError = true
            }
        }
    }
    
    var progress: some View {
        ZStack {
            Color.black
                .opacity(0.09)
                .background(.ultraThinMaterial)
            ProgressView().scaleEffect(1.77)
        }.edgesIgnoringSafeArea(.all)
    }
    
    @State private var scaleable = false
    @State private var analyzeError = false
    @State private var errorMessage = ""
    @State private var showAnalysis = false
    @State private var textFromImage = ""
    
    private func getTextFromImage(_ image: UIImage?) {
        DispatchQueue.global(qos: .background).async {
            let request = VNRecognizeTextRequest()
            guard let image = image?.cgImage else {
                detective.ImageErrorStatus = .convert
                detective.showImageError = true
                detective.imageAnalyzingStatus = .idle
                return
            }
            let handler = VNImageRequestHandler(cgImage: image)
            do {
                try handler.perform([request])
                if let results = request.results {
                    textFromImage = ""
                    for result in results {
                        if let bestCandidate = result.topCandidates(1).first {
                            textFromImage += bestCandidate.string + "\n"
                        }
                    }
                    DispatchQueue.main.async {
                        detective.imageAnalyzingStatus = .idle
                    }
                    if textFromImage.count == 0 {
                        detective.ImageErrorStatus = .noneText
                        detective.showImageError = true
                    } else {
                        showAnalysis = true
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
                analyzeError = true
                detective.imageAnalyzingStatus = .idle
            }
        }
    }
    
    var grayScale: some View {
        Button {
            Noir()
        } label: {
            Text("to grayScale")
        }
    }
    
    private func Noir() {
        if detective.currentImage != nil {
            let context = CIContext(options: nil)
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: detective.currentImage!), forKey: kCIInputImageKey)
            if let outputImage = currentFilter?.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgImage)
                self.detective.setImage(processedImage)
            }
        } else {
            detective.ImageErrorStatus = .noneImage
            detective.showImageError = true
        }
    }
    
    var resetButton: some View {
        Button {
            reset()
        } label: {
            Text("reset")
        }
    }
    
    private func reset() {
        self.detective.setImage(cloneImage)
        brightness = 0
        contrast = 1
        saturation = 1
        rotationDegrees = 0
        scale = 1
        scaleable = false
    }
    
    // MARK: - Sliders
    
    @ViewBuilder var editImageConstructs: some View {
        VStack {
            HStack {
                brightnessSlider
                contrastSlider
            }
            HStack {
                rotateSlider
                saturationSlider
            }
            if scaleable && detective.currentImage != nil {
                scaleSlider
            }
        }
        .tint(.black)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1).foregroundColor(.black))
        .padding(.horizontal, 20)
    }
    
    @State private var brightness: Double = 0.1
    
    private let brightnessBounds: ClosedRange<Double> = 0...0.5
    
    var brightnessSlider: some View {
        SliderBar("brightness", size: screenWidth/4, bounds: brightnessBounds, value: $brightness)
    }
    
    @State private var contrast: Double = 1
    
    var contrastSlider: some View {
        SliderBar("contrast", size: screenWidth/4, bounds: 0...3, value: $contrast)
    }
    
    @State private var rotationDegrees: Double = 0
    
    var rotateSlider: some View {
        SliderBar("rotation", size: screenWidth/4, bounds: 0...360, value: $rotationDegrees)
    }
    
    @State private var saturation: Double = 1
    
    var saturationSlider: some View {
        SliderBar("saturation", size: screenWidth/4, bounds: -3...3, value: $saturation)
    }
    
    @State private var scale: Double = 1
    
    var scaleSlider: some View {
        SliderBar("scale", size: screenWidth/2, bounds: 1...4, value: $scale)
    }
}
