//
//  AuthenticatedAPIClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

class AuthenticatedAPIClient: NewAPIClient {
    let token: String
    
    init(baseUrl: URL, token: String) {
        self.token = token
        super.init(baseUrl: baseUrl)
    }
    
    override func urlRequest(from definition: any APIRequest) throws -> URLRequest {
        var urlRequest = try super.urlRequest(from: definition)
        
        // TODO: 0.18 deprecation remove this
        urlRequest.url?.append(queryItems: [.init(name: "auth", value: token)])
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
