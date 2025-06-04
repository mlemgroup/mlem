//
//  RestClient
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-04.
//

import Foundation

class RestClient<ErrorType: Decodable & CustomStringConvertible> {
    let decoder: JSONDecoder = .defaultDecoder
    
    let urlSession: URLSession = .init(configuration: .default)
    
    func perform<Request: ApiRequest>(
        baseUrl: URL,
        _ request: Request,
        token: String?
    ) async throws(RestError) -> Request.Response {
        let urlRequest = try urlRequest(baseUrl: baseUrl, request: request, token: token)
        // this line intentionally left commented for convenient future debugging
        // urlRequest.debug()
        let (data, response) = try await execute(urlRequest)
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 500 { // Error code for server being offline.
                throw .serverError(statusCode: response.statusCode)
            }
            
            if let apiError = try? decoder.decode(ErrorType.self, from: data) {
                // at present we have a single error model which appears to be used throughout
                // the API, however we may way to consider adding the error model type as an
                // associated value in the same was as the response to allow requests to define
                // their own error models when necessary, or drop back to this as the default...
                
                throw .response(String(describing: apiError), statusCode: response.statusCode)
            }
        }
        
        return try decode(Request.Response.self, from: data)
    }
    
    func execute(_ urlRequest: URLRequest) async throws(RestError) -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: urlRequest)
        } catch {
            if case URLError.cancelled = error as NSError {
                throw .cancelled
            } else {
                throw .networking(error)
            }
        }
    }
    
    func urlRequest(
        baseUrl: URL,
        request: any ApiRequest,
        token: String?
    ) throws(RestError) -> URLRequest {
        let url: URL
        do {
            url = try request.endpoint(base: baseUrl)
        } catch {
            throw .parameterEncoding(error)
        }
        
        var urlRequest = mlemUrlRequest(url: url)
        for header in request.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if request as? any ApiGetRequest != nil {
            urlRequest.httpMethod = "GET"
        } else if let postDefinition = request as? any ApiPostRequest {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try createBodyData(for: postDefinition)
        } else if let putDefinition = request as? any ApiPutRequest {
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = try createBodyData(for: putDefinition)
        } else if let deleteDefinition = request as? any ApiDeleteRequest {
            urlRequest.httpMethod = "DELETE"
            urlRequest.httpBody = try createBodyData(for: deleteDefinition)
        }
        
        if let token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    func createBodyData(for defintion: any ApiRequestBodyProviding) throws(RestError) -> Data {
        do {
            let encoder = JSONEncoder()
            let body = defintion.body ?? ""
            return try encoder.encode(body)
        } catch {
            throw .encoding(error)
        }
    }
    
    private func decode<T: Decodable>(_ model: T.Type, from data: Data) throws(RestError) -> T {
        do {
            return try decoder.decode(model, from: data)
        } catch {
            throw .decoding(data, error)
        }
    }
}
