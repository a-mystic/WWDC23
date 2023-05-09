//
//  DetectiveView.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import RealityKit
import SwiftUI
import ARKit
import Combine

final class DetectiveViewController: UIViewController, ARSessionDelegate {
    private var cancellable: AnyCancellable?
    private var foundObject = ModelEntity()
    private lazy var gameObject = try! Entity.loadAnchor(named: "DetectiveGame")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFoundObject()
        ARManager.arView = ARView(frame: self.view.frame)
        ARManager.arView.session.delegate = self
        Detection()
        ARManager.arView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PanGesture(recognizer:))))
        self.view.addSubview(ARManager.arView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        ARManager.arView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func loadFoundObject() {
        cancellable = Entity.loadModelAsync(named: "foundObject")
            .sink { error in
                self.cancellable?.cancel()
            } receiveValue: { entity in
                self.foundObject = entity
            }
    }
    
    @objc private func PanGesture(recognizer: UIPanGestureRecognizer) {
        let tapLocation = recognizer.location(in: ARManager.arView)
        let allowing = ARRaycastQuery.Target.estimatedPlane
        var raycasts = ARManager.arView.raycast(from: tapLocation, allowing: allowing, alignment: .vertical)
        if let firstRaycast = raycasts.first {
            let worldPosition = simd_make_float3(firstRaycast.worldTransform.columns.3)
            let model = createDrawObject()
            placeObject(model, at: worldPosition)
        }
        raycasts = ARManager.arView.raycast(from: tapLocation, allowing: allowing, alignment: .horizontal)
        if let firstRaycast = raycasts.first {
            let worldPosition = simd_make_float3(firstRaycast.worldTransform.columns.3)
            let model = createDrawObject()
            placeObject(model, at: worldPosition)
        }
    }
    
    func Detection() {
        switch ARManager.mode {
        case .idle: detectPlane()
        case .imageDetection: detectImage()
        case .game: createGame()
        }
    }

    func detectPlane() {
        ARManager.arView.automaticallyConfigureSession = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        ARManager.arView.session.run(configuration)
    }
    
    private func createDrawObject() -> ModelEntity {
        let object = MeshResource.generateSphere(radius: 0.004)
        let Material = SimpleMaterial(color: ARManager.materialColor, roughness: 0, isMetallic: false)
        let objectEntity = ModelEntity(mesh: object, materials: [Material])
        return objectEntity
    }

    func erase() {
        ARManager.arView.scene.anchors.removeAll()
        ARManager.mode = .idle
        Detection()
    }

    private func placeObject(_ object: ModelEntity, at location: SIMD3<Float>) {
        let objectAnchor = AnchorEntity(world: location)
        objectAnchor.addChild(object)
        ARManager.arView.scene.addAnchor(objectAnchor)
    }
    
    func detectImage() {
        if let image = ARManager.targetImage?.cgImage {
            let referenceImage = ARReferenceImage(image, orientation: .up, physicalWidth: 1)
            ARManager.ImageReferenceSet.insert(referenceImage)
            let configuration = ARImageTrackingConfiguration()
            configuration.isAutoFocusEnabled = true
            configuration.trackingImages = ARManager.ImageReferenceSet
            configuration.maximumNumberOfTrackedImages = 1
            ARManager.arView.session.run(configuration)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                createArrowOnTarget(foundObject, at: imageAnchor)
            }
        }
    }
    
    private func createArrowOnTarget(_ arrow: ModelEntity, at imageAnchor: ARImageAnchor) {
        let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
        let rotationAngle = simd_quatf(angle: 0, axis: SIMD3<Float>(x: 0, y: 0, z: 0))
        arrow.setOrientation(rotationAngle, relativeTo: imageAnchorEntity)
        arrow.setPosition(SIMD3<Float>(x: 0, y: 0, z: 0), relativeTo: imageAnchorEntity)
        imageAnchorEntity.addChild(arrow)
        ARManager.arView.scene.addAnchor(imageAnchorEntity)
    }
    
    func createGame() {
        erase()
        gameObject.scale *= 0.8
        ARManager.arView.scene.anchors.append(gameObject)
    }
}

struct DetectiveView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DetectiveViewController { DetectiveViewController() }
    
    func updateUIViewController(_ uiViewController: DetectiveViewController, context: Context) { }
}
