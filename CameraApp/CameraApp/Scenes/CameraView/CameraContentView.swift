//
//  CameraContentView.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct CameraContentView: View {
    @EnvironmentObject private var viewModel: CameraView.ViewModel

    @State private var isShowingPreviewView = false
    @State private var photo: CapturedPhotoData? = nil

    var image: Image?

    private let label = Text("Camera feed")

    var body: some View {
        ZStack {
            if let image = image {
                GeometryReader { geometry in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipped()
                }
            } else {
                Color.black
            }

            VStack {
                Spacer()

                Button {
                    viewModel.imageCaptureProvider.takePhoto()
                } label: {
                    NavigationLink(
                        destination: PreviewView(photoData: $photo),
                        isActive: $isShowingPreviewView
                    ) {
                        Image(systemName: "circle.inset.filled")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .foregroundColor(.red)
                    }
                    .isDetailLink(false)
                    .disabled(true)
                    .padding(.bottom, 100)
                }
                .disabled(image == nil)
            }
        }
        .onChange(of: photo) { newValue in
            newValue == nil
                ? viewModel.start()
                : viewModel.stopFrames()
        }
        .onReceive(viewModel.$capturedPhoto) { capturedPhoto in
            guard let capturedPhoto = capturedPhoto else { return }

            photo = capturedPhoto
            isShowingPreviewView = true
        }
    }
}

struct CameraContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraContentView()
    }
}
