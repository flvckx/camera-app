//
//  PhotoData.swift
//  
//
//  Created by Serhii Palash on 14/08/2022.
//

import Fluent
import Vapor

final class PhotoData: Model, Content {
    static let schema = "photos"

    @ID(key: .id) var id: UUID?
    @Field(key: "user_id") var userId: Int
    @Field(key: "timestamp") var timestamp: String
    @Field(key: "image_url") var imageUrl: String?
}
