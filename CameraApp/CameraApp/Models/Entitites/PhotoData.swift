//
//  PhotoData.swift
//  CameraApp
//
//  Created by Serhii Palash on 13/08/2022.
//

import SwiftUI

struct PhotoData {
    let timestamp: Date = .now
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

extension PhotoData: Equatable {
    static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
}
