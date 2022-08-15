//
//  UploadView.swift
//  CameraApp
//
//  Created by Serhii Palash on 14/08/2022.
//

import SwiftUI

struct UploadView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.rootPresentationMode) var rootMode

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 150)

                Text("")
                    .padding(.top, 15)

                Spacer()

                Button {
                    viewModel.upload()
                    viewModel.savePhoto()
                } label: {
                    Text("Upload")
                        .frame(width: 200, height: 60)
                        .border(.blue, width: 1)
                }
                .padding(.bottom, 100)
                .disabled(viewModel.isUploading || viewModel.isSuccess == true)
            }
            .navigationBarHidden(true)
            .onBackSwipe { dismiss() }

            if viewModel.isUploading {
                ProgressView()
            }
        }
        .onReceive(viewModel.$isSuccess) { isSuccess in
            guard isSuccess == true else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                rootMode.wrappedValue.dismiss()
            }
        }
    }

    private var imageName: String {
        guard let isSuccess = viewModel.isSuccess else { return "icloud.and.arrow.up" }
        return isSuccess ? "checkmark.icloud" : "xmark.icloud"
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(viewModel: .init(
            capturedPhotoData: CapturedPhotoData(
                thumbnailImage: Image(systemName: ""),
                thumbnailSize: (0, 0),
                imageData: Data(),
                imageSize: (0, 0)
            )
        ))
    }
}
