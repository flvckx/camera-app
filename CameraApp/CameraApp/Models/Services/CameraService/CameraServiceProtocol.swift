//
//  CameraServiceProtocol.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import AVFoundation

protocol CameraServiceProtocol: NSObjectProtocol {
    var error: Published<CameraServiceError?>.Publisher { get }
    var outputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate? { get set }
    var photoCaptureDelegate: AVCapturePhotoCaptureDelegate? { get set }

    func start() async
    func stop()
    func takePhoto()
}
