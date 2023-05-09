//
//  UtilityViews.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI
import PhotosUI
import PencilKit

struct Close: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            DetectiveViewController().Detection()
            dismiss.callAsFunction()
        } label: {
            Text("Close")
        }
    }
}

struct Camera: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()
        camera.delegate = context.coordinator
        camera.allowsEditing = false
        camera.sourceType = .camera
        return camera
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            DetectiveViewController().Detection()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                ARManager.targetImage = image
            }
            picker.dismiss(animated: true)
            ARManager.mode = .imageDetection
            DetectiveViewController().Detection()
        }
    }
}

struct Photo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                picker.dismiss(animated: true)
                return
            }
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            ARManager.targetImage = image
                            ARManager.mode = .imageDetection
                            DetectiveViewController().Detection()
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
}

struct SliderBar<Value>: View where Value: Comparable, Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint {
    let name: String
    let bounds: ClosedRange<Value>
    let width: CGFloat
    
    @Binding var value: Value
    
    init(_ name: String, size width: CGFloat, bounds: ClosedRange<Value>, value: Binding<Value>) {
        self.name = name
        self.width = width
        self.bounds = bounds
        self._value = value
    }
    
    var body: some View {
        HStack {
            Text(name)
            Slider(value: $value, in: bounds)
                .frame(width: width)
                .padding(.horizontal, 30)
        }
    }
}

struct Magnifier<Content: View>: View {
    var content: Content
    var scale: CGFloat
    
    init(scale: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.scale = scale
    }
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let circleSize: CGFloat = 220
    
    var body: some View {
        content
            .reverseMask {
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .offset(offset)
            }
            .overlay {
                GeometryReader { geometry in
                    content
                        .offset(x: -offset.width, y: -offset.height)
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(1 + scale)
                        .clipShape(Circle())
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    Circle()
                        .fill(.clear)
                        .frame(width: circleSize, height: circleSize)
                        .overlay(alignment: .topLeading) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(1.35, anchor: .topLeading)
                                .offset(x: -10, y: -5)
                                .fontWeight(.thin)
                        }
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let offsetValue = value.translation + lastOffset
                        offset = offsetValue
                    }.onEnded { _ in
                        lastOffset = offset
                    }
            )
    }
}


struct Drawing: UIViewRepresentable {
    let canvasView: PKCanvasView
    private let picker = PKToolPicker()
    
    init(_ canvasView: PKCanvasView) {
        self.canvasView = canvasView
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        self.canvasView.backgroundColor = .white
        self.canvasView.becomeFirstResponder()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        picker.overrideUserInterfaceStyle = .light
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: uiView)
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
}

struct AnalyzedTextView: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    Text(text)
                        .font(.body)
                        .bold()
                        .frame(maxWidth: geometry.size.width)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Close().foregroundColor(.blue) } }
        }
    }
}

struct sliderBackground: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.14), .black.opacity(0.14),.white.opacity(0.04)]), startPoint: .topLeading, endPoint: .bottom))
            .edgesIgnoringSafeArea(.all)
            .background(.ultraThinMaterial)
    }
}

var blurView: some View {
    ZStack {
        Rectangle().foregroundColor(.gray.opacity(0.14))
        Rectangle().fill(.regularMaterial)
    }.edgesIgnoringSafeArea(.all)
}

var okayButton: some View {
    Button("Ok") { }
}
