//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-04.
//

import Foundation

public enum RestError: Error {
    case serverError(statusCode: Int) // Should always be a 5xx status code
    case response(String, statusCode: Int)
    case encoding(Error)
    case parameterEncoding(URLQueryItemEncoderError)
    case decoding(Data, Error?)
    case networking(Error)
    case cancelled
}

extension RestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .encoding(error):
            return "Unable to encode: \(error)"
        case let .networking(error):
            return "Networking error: \(error)"
        case let .response(errorResponse, status):
            return "Response error: \(errorResponse) with status \(status)"
        case let .serverError(statusCode):
            return "Server Error: \(statusCode)"
        case .cancelled:
            return "Cancelled"
        case let .decoding(data, error):
            guard let string = String(data: data, encoding: .utf8) else {
                return localizedDescription
            }
            if let error {
                return "Unable to decode: \(string)\nError: \(error)"
            }
            return "Unable to decode: \(string)"
        case let .parameterEncoding(error):
            return "Unable to encode request parameters: \(error)"
        }
    }
}
