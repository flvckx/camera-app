//
//  PreviewView.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct PreviewView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var photoData: PhotoData?

    private let label = Text("Captured image")

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                photoData?
                    .thumbnailImage
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center)
                    .clipped()
            }

            VStack {
                Spacer()

                HStack {
                    Button {
                        photoData = nil
                        dismiss()
                    } label: {
                        Text("Retake")
                            .frame(width: 100, height: 60)
                            .border(.blue, width: 1)
                    }
                    .padding(.bottom, 100)

                    Spacer()

                    Button {
                        // todo upload
                    } label: {
                        Text("Continue")
                            .frame(width: 100, height: 60)
                            .border(.blue, width: 1)
                    }
                    .padding(.bottom, 100)
                }
                .padding([.leading, .trailing], 40)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(photoData: .constant(nil))
    }
}
