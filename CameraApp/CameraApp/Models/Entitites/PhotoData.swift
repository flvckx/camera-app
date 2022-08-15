//
//  PhotoData.swift
//  CameraApp
//
//  Created by Serhii Palash on 14/08/2022.
//

struct PhotoData: Decodable {
    let id: String
    var userId: Int?
    var timestamp: String?
    var imageUrl: String?
}
