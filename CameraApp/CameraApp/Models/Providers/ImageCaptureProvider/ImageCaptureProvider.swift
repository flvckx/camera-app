//
//  ImageCaptureProvider.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import AVFoundation
import CoreImage

final class ImageCaptureProvider: NSObject, ObservableObject {
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    private var addToPreviewStream: ((CIImage) -> Void)?

    private let cameraService: CameraServiceProtocol

    @Published var error: CameraServiceError?

    var isPreviewPaused = false

    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()

    init(cameraService: CameraServiceProtocol = CameraService()) {
        self.cameraService = cameraService

        super.init()

        cameraService.photoCaptureDelegate = self
        cameraService.outputSampleBufferDelegate = self
        cameraService.error.assign(to: &$error)
    }

    func start() async {
        await cameraService.start()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ImageCaptureProvider: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension ImageCaptureProvider: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            self.error = .photoCaptureFailed
            return
        }

        addToPhotoStream?(photo)
    }
}
