//
//  ApiRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

// MARK: - ApiRequest

enum ApiRequestError: Error {
    case authenticationRequired
    case undefinedSession
}

protocol ApiRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var headers: [String: String] { get }
    
    func endpoint(base: URL) throws(URLQueryItemEncoderError) -> URL
}

extension ApiRequest {
    var headers: [String: String] { defaultHeaders }

    var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}

// MARK: - ApiGetRequest

protocol ApiGetRequest: ApiRequest {
    associatedtype Parameters: Encodable
    var parameters: Parameters? { get }
}

extension ApiRequest {
    func endpoint(base: URL) throws(URLQueryItemEncoderError) -> URL {
        base
            .appending(path: path)
    }
}

extension ApiGetRequest {
    func endpoint(base: URL) throws(URLQueryItemEncoderError) -> URL {
        if let parameters {
            try base
                .appending(path: path)
                .appending(queryItems: URLQueryItemEncoder.encode(parameters))
        } else {
            base
                .appending(path: path)
        }
    }
}

// MARK: - ApiRequestBodyProviding

protocol ApiRequestBodyProviding: ApiRequest {
    associatedtype Body: Encodable
    var body: Body? { get }
}

protocol ApiPostRequest: ApiRequestBodyProviding {}
protocol ApiPutRequest: ApiRequestBodyProviding {}
protocol ApiDeleteRequest: ApiRequestBodyProviding {}
