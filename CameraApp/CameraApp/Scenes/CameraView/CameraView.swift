//
//  CameraView.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        CameraContentView(image: viewModel.previewImage)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .onBackSwipe { dismiss() }
            .environmentObject(viewModel)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
