//
//  CameraView+ViewModel.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

extension CameraView {
    @MainActor class ViewModel: ObservableObject {
        @Published var previewImage: Image?
        @Published var capturedPhoto: CapturedPhotoData?

        var imageCaptureProvider = ImageCaptureProvider()

        let userId: Int

        init(userId: Int) {
            self.userId = userId
            
            Task {
                await imageCaptureProvider.start()
            }

            Task {
                await handleCameraPreviews()
            }

            Task {
                await handleCameraPhotos()
            }
        }

        func start() {
            Task {
                await imageCaptureProvider.start()
            }

            imageCaptureProvider.isPreviewPaused = false
        }

        func stopFrames() {
            imageCaptureProvider.isPreviewPaused = true
            previewImage = nil
            imageCaptureProvider.stop()
        }

        private func handleCameraPreviews() async {
            let imageStream = imageCaptureProvider.previewStream
                .map { $0.image }

            for await image in imageStream {
                Task { @MainActor in
                    previewImage = image
                }
            }
        }

        private func handleCameraPhotos() async {
            let unpackedPhotoStream = imageCaptureProvider.photoStream
                .compactMap { $0 }

            for await var photoData in unpackedPhotoStream {
                Task { @MainActor in
                    photoData.userId = userId
                    previewImage = photoData.thumbnailImage
                    capturedPhoto = photoData
                }
            }
        }
    }
}
