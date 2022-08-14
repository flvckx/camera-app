//
//  PhotoDataController.swift
//  
//
//  Created by Serhii Palash on 14/08/2022.
//

import Vapor

final class PhotoDataController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("upload-image", use: uploadImage)
    }

    // MARK: Multipart
    private func uploadImage(req: Request) throws -> EventLoopFuture<Response> {
        let userId = req.parameters.get("user_id", as: Int.self)
        let timestamp = req.parameters.get("date", as: String.self)
        let file = try req.content.decode(File.self)
        var fileName = "\(userId ?? -1)-\(timestamp ?? "")"
        fileName = file.extension.flatMap { "\(fileName).\($0)" } ?? fileName
        let path = req.application.directory.workingDirectory + fileName

        guard file.isImage else { throw Abort(.badRequest) }

        return req
            .fileio
            .writeFile(file.data, at: path)
            .map { _ -> EventLoopFuture<PhotoData> in
                let photoData = PhotoData(
                    userId: userId,
                    date: timestamp,
                    imageUrl: path
                )

                return photoData
                    .save(on: req.db)
                    .map { photoData }
            }
            .encodeResponse(status: .accepted, for: req)
    }
}

// MARK: - File + isImage
extension File {
    var isImage: Bool {
        [
            "png",
            "jpeg",
            "jpg",
            "gif"
        ]
            .contains(self.extension?.lowercased())
    }
}
