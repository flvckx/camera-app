//
//  CIImage+.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
