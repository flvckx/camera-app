//
//  CameraService.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import AVFoundation

final class CameraService: NSObject, CameraServiceProtocol {
    // session
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera-app.camera-service-queue")
    // input
    private var deviceInput: AVCaptureDeviceInput?

    private let captureDevice: AVCaptureDevice? = {
        return AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera,
                .builtInWideAngleCamera, .builtInDualWideCamera
            ],
            mediaType: .video,
            position: .front
        )
        .devices
        .first ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }()
    // outputs
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?

    private var isCaptureSessionConfigured = false

    @Published var publishedError: CameraServiceError?

    var error: Published<CameraServiceError?>.Publisher { $publishedError }

    weak var outputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    weak var photoCaptureDelegate: AVCapturePhotoCaptureDelegate?

    let videoOutputQueue = DispatchQueue(label: "camera-app.camera-video-output-queue")

    func start() async {
        guard await checkAuthorization() else { return }

        guard !isCaptureSessionConfigured else {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }

            return
        }

        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }

    func stop() {
        guard isCaptureSessionConfigured else { return }

        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }

    func takePhoto() {
        guard
            let photoOutput = photoOutput,
            let photoCaptureDelegate = photoCaptureDelegate else { return }

        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()

            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            photoSettings.isHighResolutionPhotoEnabled = true

            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .balanced

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported {
                    photoOutputVideoConnection.videoOrientation = .portrait
                }

                if photoOutputVideoConnection.isVideoMirroringSupported {
                    photoOutputVideoConnection.isVideoMirrored = true
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
        }
    }

    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()

            return status
        case .denied:
            publishedError = .deniedAuthorization
            return false
        case .restricted:
            publishedError = .restrictedAuthorization
            return false
        @unknown default:
            publishedError = .unknownAuthorization
            return false
        }
    }

    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false

        captureSession.beginConfiguration()

        defer {
            captureSession.commitConfiguration()
            completionHandler(success)
        }

        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
                publishedError = .cannotAddInput
                return
            }

        let photoOutput = AVCapturePhotoOutput()
        captureSession.sessionPreset = .photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(outputSampleBufferDelegate, queue: videoOutputQueue)

        guard captureSession.canAddInput(deviceInput) else {
            publishedError = .cannotAddInput
            return
        }

        guard captureSession.canAddOutput(photoOutput) else {
            publishedError = .cannotAddPhotoOutput
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            publishedError = .cannotAddVideoOutput
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput

        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality

        if let videoConnection = videoOutput.connection(with: .video) {
            videoConnection.videoOrientation = .portrait

            if videoConnection.isVideoMirroringSupported {
                videoConnection.isVideoMirrored = true
            }
        }

        isCaptureSessionConfigured = true
        success = true
    }
}
