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

    var image: Image?

    private let label = Text("Camera feed")

    var body: some View {
        ZStack {
            if let image = image {
                GeometryReader { geometry in
                    image
//                    Image(image, scale: 1.0, orientation: .upMirrored, label: label)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center)
                        .clipped()
                }
            } else {
                Color.black
            }

            VStack {
                Spacer()

                Button {
                    // capture
                    isShowingPreviewView = true
                } label: {
                    NavigationLink(
                        destination: navigationDestination,
                        isActive: $isShowingPreviewView
                    ) {
                        Image(systemName: "circle.inset.filled")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .foregroundColor(.red)
                    }
                    .disabled(viewModel.capturedPhoto == nil)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    private var navigationDestination: some View {
        Group {
            if let photo = viewModel.capturedPhoto {
                EmptyView()
                // PreviewView(image: photo)
            } else {
                EmptyView()
            }
        }
    }
}

struct CameraContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraContentView()
    }
}
