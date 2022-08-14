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
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(PhotoData.schema)
            .delete()
    }
}
