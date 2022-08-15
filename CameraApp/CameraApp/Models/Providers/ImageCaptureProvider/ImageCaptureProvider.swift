//
//  ImageCaptureProvider.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import AVFoundation
import CoreImage
import SwiftUI

final class ImageCaptureProvider: NSObject, ObservableObject {
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    private var addToPreviewStream: ((CIImage) -> Void)?

    private let cameraService: CameraServiceProtocol

    @Published var error: CameraServiceError?

    var isPreviewPaused = false

    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { [weak self] ciImage in
                guard let self = self else { return }
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()

    lazy var photoStream: AsyncStream<CapturedPhotoData?> = {
        AsyncStream { continuation in
            addToPhotoStream = { [weak self] photo in
                guard let self = self else { return }
                let photoData = self.unpackPhoto(photo)
                continuation.yield(photoData)
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

    func stop() {
        cameraService.stop()
    }

    func takePhoto() {
        cameraService.takePhoto()
    }

    private func unpackPhoto(_ photo: AVCapturePhoto) -> CapturedPhotoData? {
        guard
            let imageData = photo.fileDataRepresentation(),
            let previewCGImage = photo.previewCGImageRepresentation(),
            let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
            let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }

        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)

        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))

        return CapturedPhotoData(
            thumbnailImage: thumbnailImage,
            thumbnailSize: thumbnailSize,
            imageData: imageData,
            imageSize: imageSize
        )
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

// MARK: - Image.Orientation
fileprivate extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
