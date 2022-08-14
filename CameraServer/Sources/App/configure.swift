import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "10mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))

    // MARK: Database
    app.databases.use(.sqlite(.memory), as: .sqlite)

    // MARK: Migrations
    app.migrations.add(CreatePhotoDataMigration(), to: .sqlite)
    try app.autoMigrate().wait()

    // MARK: Routes
    try routes(app)
}
