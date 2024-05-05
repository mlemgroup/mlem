//
//  DeletePictrsFile.swift
//  Mlem
//
//  Created by Sjmarf on 29/09/2023.
//

import Foundation

struct ImageDeleteRequest: APIDeleteRequest {
    var path: String
    var instanceURL: URL
    
    var endpoint: URL {
        instanceURL
            .appending(path: path)
    }
    
    typealias Response = ImageDeleteResponse
    
    init(session: APISession, file: String, deleteToken: String) throws {
        var components = URLComponents()
        components.scheme = try session.instanceUrl.scheme
        components.host = try session.instanceUrl.host
        components.path = "/pictrs/image"
        
        guard let url = components.url else {
            throw APIClientError.response(.init(error: "Failed to modify instance URL to delete from pictrs."), nil)
        }
        self.instanceURL = url
        
        self.path = "/delete/\(deleteToken)/\(file)"
    }
}

struct ImageDeleteResponse: Decodable {}
