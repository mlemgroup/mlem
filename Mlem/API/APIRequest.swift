//
//  APIRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

// MARK: - APIRequest

protocol APIRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var instanceURL: URL { get }
    var endpoint: URL { get }
    var headers: [String: String] { get }
}

extension APIRequest {
    var headers: [String: String] { defaultHeaders }

    var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}

// MARK: - APIGetRequest

protocol APIGetRequest: APIRequest {
    var queryItems: [URLQueryItem] { get }
}

extension APIGetRequest {
    var endpoint: URL {
        instanceURL
        .appending(path: path)
        .appending(queryItems: queryItems.filter {
            item in item.value != nil
        })
    }
}

// MARK: - APIRequestBodyProviding

protocol APIRequestBodyProviding: APIRequest {
    associatedtype Body: Encodable
    var body: Body { get }
}

extension APIRequestBodyProviding {
    var endpoint: URL {
        instanceURL
        .appending(path: path)
    }
}

// MARK: - APIPostRequest

protocol APIPostRequest: APIRequestBodyProviding {}

// MARK: - APIPutRequest

protocol APIPutRequest: APIRequestBodyProviding {}
