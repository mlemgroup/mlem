//
//  ApiRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

// MARK: - RestRequest

public protocol RestRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var headers: [String: String] { get }
    
    func endpoint(base: URL) throws(URLQueryItemEncoderError) -> URL
}

public extension RestRequest {
    var headers: [String: String] { defaultHeaders }

    var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}

// MARK: - GetRequest

public protocol GetRequest: RestRequest {
    associatedtype Parameters: Encodable
    var parameters: Parameters? { get }
}

public extension RestRequest {
    func endpoint(base: URL) throws(URLQueryItemEncoderError) -> URL {
        base
            .appending(path: path)
    }
}

public extension GetRequest {
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

// MARK: - RequestWithBody

public enum RequestWithBodyMethod {
    case post, put, delete
}

public protocol RequestWithBody: RestRequest {
    associatedtype Body: Encodable
    var body: Body? { get }
    var method: RequestWithBodyMethod { get }
}

public protocol PostRequest: RequestWithBody { }

public extension PostRequest {
    var method: RequestWithBodyMethod { .post }
}

public protocol PutRequest: RequestWithBody { }

public extension PutRequest {
    var method: RequestWithBodyMethod { .put }
}

public protocol DeleteRequest: RequestWithBody { }

public extension DeleteRequest {
    var method: RequestWithBodyMethod { .delete }
}
