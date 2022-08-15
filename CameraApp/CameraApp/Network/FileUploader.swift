//
//  FileUploader.swift
//  CameraApp
//
//  Created by Serhii Palash on 14/08/2022.
//

import Foundation
import Combine

public class FileUploader: NSObject {
    static let shared = FileUploader()

    // Set your host address
    static let hostIp = "[your_server_ip_address]:8080"

    let baseUrl: URL? = {
        let baseUrl = URL(string: "http://\(hostIp)/")
        if baseUrl?.absoluteString.contains("server_ip_address") ?? true {
            print("WARNING: Server ip address is not set. Please, set your server address.")
        }
        return baseUrl
    }()

    private lazy var urlSession: URLSession = URLSession(configuration: .default)

    lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private override init() {
        super.init()
    }

    func createAction(parameters: UploadPhotoParameters) async throws -> PhotoData {
        guard let createUrl = baseUrl else { throw NetworkError.brokenUrl }

        var request = URLRequest(url: createUrl)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await urlSession.data(for: request)
        return try photoData(data, response: response)
    }

    func upload(_ data: Data, path: String) async throws -> PhotoData {
        guard let uploadUrl = URL(string: "http://\(Self.hostIp)/\(path)/upload-image") else {
            throw NetworkError.brokenUrl
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: uploadUrl, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        // Headers
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Body
        request.httpBody = createHttpBody(
            binaryData: data,
            boundary: boundary
        )

        let (data, response) = try await urlSession.data(for: request)
        return try photoData(data, response: response)
    }

    private func createHttpBody(binaryData: Data, boundary: String) -> Data {
        var data = Data()

        let fileName = "Image.heic"
        // Add the filename field and its value
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"filename\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fileName)".data(using: .utf8)!)
        // Add the data field and mime type
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"data\"\r\n\r\n".data(using: .utf8)!)
        data.append(binaryData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return data
    }

    private func photoData(_ data: Data, response: URLResponse) throws -> PhotoData {
        guard let response = response as? HTTPURLResponse else { throw NetworkError.requestFailed }

        switch response.statusCode {
        case 200..<300:
            return try decoder.decode(PhotoData.self, from: data)
        default:
            throw NetworkError.requestFailed
        }
    }
}
