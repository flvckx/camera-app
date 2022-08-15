//
//  CreatePhotoDataMigration.swift
//  
//
//  Created by Serhii Palash on 14/08/2022.
//

import Fluent

struct CreatePhotoDataMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PhotoData.schema)
            .id()
            .field("user_id", .int, .required)
            .field("image_url", .string)
            .field("timestamp", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PhotoData.schema)
            .delete()
    }
}
