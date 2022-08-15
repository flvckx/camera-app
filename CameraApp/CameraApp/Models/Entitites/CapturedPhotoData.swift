//
//  PhotoData.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct CapturedPhotoData {
    let timestamp: Date = .now
    var userId: Int?
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

extension CapturedPhotoData: Equatable {
    static func == (lhs: CapturedPhotoData, rhs: CapturedPhotoData) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}
