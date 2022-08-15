//
//  PhotoDataController.swift
//  
//
//  Created by Serhii Palash on 14/08/2022.
//

import Vapor
import Foundation

final class PhotoDataController: RouteCollection {
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func boot(routes: RoutesBuilder) throws {
        routes.post(use: postEntity)

        let singleUserRoutes = routes.grouped(":id")
        singleUserRoutes.post("upload-image", use: uploadImage)
    }

    // MARK: Multipart
    private func uploadImage(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = req.parameters.get("id", as: UUID.self)
        let file = try req.content.decode(File.self)
        var fileName = "\(uuid?.uuidString ?? "").\(Date().timeIntervalSince1970)"
        fileName = file.extension.flatMap { "\(fileName).\($0)" } ?? fileName
        let path = req.application.directory.workingDirectory + fileName

        guard file.isImage else { throw Abort(.badRequest) }

        return PhotoData
            .find(uuid, on: req.db)
            .unwrap(orError: Abort(.notFound))
            .flatMap { photoData in
                req
                    .fileio
                    .writeFile(file.data, at: path)
                    .map { photoData }
            }
            .flatMap { photoData in
                let hostname = req.application.http.server.configuration.hostname
                let port = req.application.http.server.configuration.port
                photoData.imageUrl = "\(hostname):\(port)/\(path)"
                return photoData
                    .update(on: req.db)
                    .map { photoData }
                    .encodeResponse(status: .accepted, for: req)
          }
    }

    // MARK: POST
    private func postEntity(req: Request) throws -> EventLoopFuture<Response> {
        let photoData = try req.content.decode(PhotoData.self, using: decoder)
        return photoData.save(on: req.db)
            .map { photoData }
            .encodeResponse(status: .created, for: req)
    }
}

// MARK: - File + isImage
extension File {
    var isImage: Bool {
        [
            "png",
            "jpeg",
            "jpg",
            "gif",
            "hevc",
            "heic",
            "heif",
            "heifs",
            "heic",
            "heics",
            "avci",
            "avcs",
            "avif",
            "avifs"
        ]
            .contains(self.extension?.lowercased())
    }
}
