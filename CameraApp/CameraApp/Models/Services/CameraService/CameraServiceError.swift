//
//  CameraServiceError.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

enum CameraServiceError: Error {
    case deniedAuthorization
    case restrictedAuthorization
    case unknownAuthorization
    case cameraUnavailable
    case cannotAddInput
    case cannotAddVideoOutput
    case cannotAddPhotoOutput
    case photoCaptureFailed
}
