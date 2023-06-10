//
//  APIRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

enum APIRequestError: Error {
    case encoding
}

protocol APIRequest {
    associatedtype Response: Decodable
    
    var endpoint: URL { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
}

extension APIRequest {
    var headers: [String: String] { defaultHeaders }
    
    var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var queryItems: [URLQueryItem] { .init() }
}
