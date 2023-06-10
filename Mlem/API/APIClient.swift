//
//  APIClient.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation

extension JSONDecoder {
    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let formatter = DateFormatter()
        
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = formatter.date(from: string) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: string) {
                return date
            }
            
            // TODO: is there somewhere that covers all the formats lemmy instances may return?
            // for now we'll return the current date until we know what other formats will
            // be encountered.
            return .now
        })
        return decoder
    }
}

enum HTTPMethod {
    case get
    case post(Data)
}

enum APIClientError: Error {
    case networking(Error)
    case response(APIErrorResponse)
}

class APIClient {
    
    let session: URLSession
    let decoder: JSONDecoder
    
    init(session: URLSession = .init(configuration: .default), decoder: JSONDecoder = .defaultDecoder) {
        self.session = session
        self.decoder = decoder
    }
    
    func perform<Request: APIRequest>(request: Request) async throws -> Request.Response {
        var urlRequest = URLRequest(url: request.endpoint)
        
        request.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        switch request.method {
        case .get:
            urlRequest.httpMethod = "GET"
        case .post(let body):
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body
        }
        
        let (data, _) = try await execute(urlRequest)
        if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
            // at present we have a single error model which appears to be used throughout
            // the API, however we may way to consider adding the error model type as an
            // associated value in the same was as the response to allow requests to define
            // their own error models when necessary, or drop back to this as the default...
            throw APIClientError.response(apiError)
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
}
