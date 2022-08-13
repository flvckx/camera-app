//
//  CameraServiceProtocol.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import AVFoundation

protocol CameraServiceProtocol: NSObjectProtocol {
    init(
        outputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?,
        photoCaptureDelegate: AVCapturePhotoCaptureDelegate?
    )

    func start() async
    func stop()
    func takePhoto()
}
