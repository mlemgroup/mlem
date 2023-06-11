//
//  APIClient.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation

enum HTTPMethod {
    case get
    case post(Data)
}

enum APIClientError: Error {
    case encoding(Error)
    case networking(Error)
    case response(APIErrorResponse, Int?)
}

class APIClient {
    
    let session: URLSession
    let decoder: JSONDecoder
    
    init(session: URLSession = .init(configuration: .default), decoder: JSONDecoder = .defaultDecoder) {
        self.session = session
        self.decoder = decoder
    }
    
    func perform<Request: APIRequest>(request: Request) async throws -> Request.Response {
        let urlRequest = try urlRequest(from: request)
        let (data, response) = try await execute(urlRequest)
        
        if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
            // at present we have a single error model which appears to be used throughout
            // the API, however we may way to consider adding the error model type as an
            // associated value in the same was as the response to allow requests to define
            // their own error models when necessary, or drop back to this as the default...
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APIClientError.response(apiError, statusCode)
        }
        
        return try decoder.decode(Request.Response.self, from: data)
    }
    
    private func execute(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: urlRequest)
        } catch {
            throw APIClientError.networking(error)
        }
    }
    
    private func urlRequest(from defintion: any APIRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: defintion.endpoint)
        defintion.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if let _ = defintion as? any APIGetRequest {
            urlRequest.httpMethod = "GET"
        } else if let postDefinition = defintion as? any APIPostRequest {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try createBodyData(for: postDefinition)
        } else if let putDefinition = defintion as? any APIPutRequest {
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = try createBodyData(for: putDefinition)
        }
        
        return urlRequest
    }
    
    private func createBodyData(for defintion: any APIRequestBodyProviding) throws -> Data {
        do {
            return try JSONEncoder().encode(defintion.body)
        } catch {
            throw APIClientError.encoding(error)
        }
    }
}
