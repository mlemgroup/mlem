//
//  LoginRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 05/06/2023.
//

import Foundation

struct LoginRequest: APIRequest {
    
    typealias Response = LoginResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let username_or_email: String
        let password: String
    }
    
    init(instanceURL: URL, username: String, password: String) throws {
        self.endpoint = instanceURL
            .appending(path: "user")
            .appending(path: "login")
        do {
            let data = try JSONEncoder().encode(
                Body(username_or_email: username, password: password)
            )
            
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct LoginResponse: Decodable {
    let jwt: String
}
