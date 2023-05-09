//
//  SwiftUIView.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import UIKit
import SwiftUI
import ARKit
import RealityKit

final class FacialExpressionController: UIViewController {
    @EnvironmentObject var detective: Detective
    
    var setExpression: (String) -> ()
    private var arView = ARView(frame: .zero)
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>
    
    init(expression: Binding<String>, expressionsOfRecognized: Binding<Set<String>>, _ setExpression: @escaping (String) -> Void) {
        _expression = expression
        _expressionsOfRecognized = expressionsOfRecognized
        self.setExpression = setExpression
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.arView.session.pause()
        self.arView.removeFromSuperview()
        DetectiveViewController().Detection()
    }
    
    private lazy var videoManager: VideoManager = {
        return VideoManager()
    }()
    
    private lazy var face: FaceAnchor = {
        return FaceAnchor()
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if isARTrackingSupported {
            requestPermission()
        } else {
            detective.VideoErrorStatus = .ARKitError
            detective.showVideoError = true
        }
        self.view.addSubview(arView)
    }
    
    private var isARTrackingSupported: Bool {
        ARFaceTrackingConfiguration.isSupported
    }
    
    private func requestPermission() {
        videoManager.requestPermission { [weak self] accessGranted in
            if accessGranted {
                DispatchQueue.main.async {
                    self?.setUp()
                }
            } else {
                self?.detective.VideoErrorStatus = .RequestError
                self?.detective.showVideoError = true
            }
        }
    }
    
    private func setUp() {
        let configuration = ARFaceTrackingConfiguration()
        arView.frame = view.frame
        arView.session.run(configuration)
        arView.session.delegate = self
        face.delegate = self
        self.view.addSubview(self.arView)
        videoManager.startVideoCapturing()
        addCamera()
    }
    
    private func addCamera() {
        let videoLayer = videoManager.videoLayer
        videoLayer.frame = self.view.frame
        videoLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
    }
}

extension FacialExpressionController: ARSessionDelegate, FaceAnchorDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                face.analyze(faceAnchor: faceAnchor)
            }
        }
    }
    
    func update(expression: String) {
        self.expression = expression
        self.expressionsOfRecognized.insert(expression)
        self.setExpression(expression)
    }
}

struct FacialExpressionViewRefer: UIViewControllerRepresentable {
    @EnvironmentObject var detective: Detective
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>

    func makeUIViewController(context: Context) -> FacialExpressionController {
        return FacialExpressionController(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized) { string in
            detective.setExpressions(string)
        }
    }
    
    func updateUIViewController(_ uiViewController: FacialExpressionController, context: Context) { }
}

struct FacialExpressionView: View {
    @EnvironmentObject var detective: Detective
    
    @State private var expression = ""
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                FacialExpressionViewRefer(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized)
                ZStack(alignment: .bottom) {
                    expressionsSlider
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                        .padding(.horizontal, 20)
                    currentExpression
                }
            }
        }.alert("Video Error", isPresented: $detective.showVideoError) {
            
        } message: {
            Text(detective.VideoErrorStatus.errorMessage)
        }
    }
    
    @State private var expressionsOfRecognized = Set<String>()
    
    var expressionsSlider: some View {
        VStack {
            ForEach(expressionsOfRecognized.sorted(by: >), id: \.self) { Text($0).font(.title) }   // replace to appending.
        }
        .padding(.vertical, 10)
        .background(sliderBackground())
        .clipShape(Capsule())
    }
    
    var currentExpression: some View {
        VStack {
            Text(expression)
                .font(.system(size: calcScale(expression)))
                .frame(alignment: .bottom)
            Spacer().frame(height: 20)
        }
    }
    
    private func calcScale(_ expression: String) -> CGFloat {
        var returnValue: CGFloat = 0
        if let currentExpressionValue = detective.expressions[expression] {
            let calcResult = (CGFloat(currentExpressionValue) / 10) + 50
            if calcResult > 100 {
                returnValue = 100
            } else {
                returnValue = calcResult
            }
        }
        return returnValue
    }
}
