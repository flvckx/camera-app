import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PhotoDataController())

    app.get("hello") { req -> String in
      return "Hello Vapor!"
    }
}
