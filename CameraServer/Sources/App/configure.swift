import Fluent
import FluentSQLiteDriver
import Vapor
import Network

// configures your application
public func configure(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "50mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    // MARK: Database
    app.databases.use(.sqlite(.memory), as: .sqlite)

    // MARK: Migrations
    app.migrations.add(CreatePhotoDataMigration(), to: .sqlite)
    try app.autoMigrate().wait()

    // MARK: Routes
    try routes(app)
}
