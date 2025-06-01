//
//  APIRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

protocol APIRouter {
    var environment: APIEnvironment { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIRouter {
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: environment.baseURL + path) else { return nil }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let finalURL = components.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue

        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        if let userRouter = self as? UserRouter {
            switch userRouter {
            case .uploadProfileImage(let imageData, let fileName, let mimeType):
                let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = Self.createMultipartBody(
                    data: imageData,
                    boundary: boundary,
                    fieldName: "profile",
                    fileName: fileName,
                    mimeType: mimeType
                )
                return request
            default:
                break
            }
        }

        if method != .get,
           let parameters,
           let body = try? JSONSerialization.data(withJSONObject: parameters) {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
    private static func createMultipartBody(
        data: Data,
        boundary: String,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(data)
        body.append("\(lineBreak)--\(boundary)--\(lineBreak)".data(using: .utf8)!)

        return body
    }
}
