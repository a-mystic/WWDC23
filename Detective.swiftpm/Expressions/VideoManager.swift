//
//  File.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import AVKit
import SwiftUI

protocol VideoManagerProtocol: AnyObject {
    func didReceive(sampleBuffer: CMSampleBuffer)
}

final class VideoManager: NSObject {
    @EnvironmentObject var detective: Detective
    
    weak var delegate: VideoManagerProtocol?
    
    private let captureSession = AVCaptureSession()
    private let videoDevice = AVCaptureDevice.default(for: .video)

    lazy var videoLayer: AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: captureSession)
    }()
    
    private lazy var videoOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue(label: "VideoOutput", attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit)
        output.setSampleBufferDelegate(self, queue: queue)
        output.alwaysDiscardsLateVideoFrames = true
        return output
    }()
    
    override init() {
        super.init()
        guard let videoDevice = videoDevice, let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            self.detective.VideoErrorStatus = .DeviceError
            self.detective.showVideoError = true
            return
        }
        captureSession.addInput(videoInput)
        captureSession.addOutput(videoOutput)
    }
    
    func startVideoCapturing() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func requestPermission(completion: @escaping (_ accessGranted: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { (accessGranted) in
            completion(accessGranted)
        }
    }
}

extension VideoManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didReceive(sampleBuffer: sampleBuffer)
    }
}
