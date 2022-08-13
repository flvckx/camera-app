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
        @Published var capturedPhoto: Image?

        private let imageCaptureProvider: ImageCaptureProvider

        init(imageCaptureProvider: ImageCaptureProvider = .init()) {
            self.imageCaptureProvider = imageCaptureProvider

            Task {
                await imageCaptureProvider.start()
                await handleCameraPreviews()
            }
        }

        func start() {
            imageCaptureProvider.isPreviewPaused = false
        }

        func stopFrames() {
            imageCaptureProvider.isPreviewPaused = true
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
    }
}
