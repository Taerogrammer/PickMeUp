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
}

extension APIRouter {
    var urlRequest: URLRequest? {
        guard let url = URL(string: environment.baseURL + path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        if let parameters = parameters,
           let body = try? JSONSerialization.data(withJSONObject: parameters) {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
