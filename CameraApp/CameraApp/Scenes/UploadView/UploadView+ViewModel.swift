//
//  UploadView+ViewModel.swift
//  CameraApp
//
//  Created by Serhii Palash on 14/08/2022.
//

import SwiftUI

extension UploadView {
    @MainActor final class ViewModel: ObservableObject {
        @State var isUploading: Bool = false
        @Published var isSuccess: Bool?
        @Published var photoData: PhotoData?

        var fileUploader = FileUploader.shared
        var photoGalleryService = PhotoGalleryService(smartAlbum: .smartAlbumUserLibrary)

        let formatter = DateFormatterService.iso8601

        let capturedPhotoData: CapturedPhotoData

        init(capturedPhotoData: CapturedPhotoData) {
            self.capturedPhotoData = capturedPhotoData
        }

        func upload() {
            Task {
                isUploading = true

                let uploadParameters = UploadPhotoParameters(
                    userId: capturedPhotoData.userId ?? -1,
                    timestamp: formatter.string(from: capturedPhotoData.timestamp)
                )

                guard let photoData = try? await fileUploader.createAction(parameters: uploadParameters) else {
                    isUploading = false
                    isSuccess = false
                    return
                }

                let uploadData = capturedPhotoData.imageData
                let result = try? await fileUploader.upload(uploadData, path: photoData.id)

                isUploading = false
                isSuccess = result != nil
                self.photoData = result
            }
        }

        func savePhoto() {
            Task {
                await photoGalleryService.addImage(capturedPhotoData.imageData)
            }
        }
    }
}
