//
//  ApiClientError.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

enum HTTPMethod {
    case get
    case post(Data)
}

enum ApiClientError: Error {
    case encoding(Error)
    case networking(Error)
    case response(ApiErrorResponse, Int?)
    case cancelled
    case invalidSession
    case decoding(Data, Error?)
    case insufficientPermissions
}

extension ApiClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case .insufficientPermissions:
            return "Insufficient permissions. Check `ApiClient.permissions`"
        case let .encoding(error):
            return "Unable to encode: \(error)"
        case let .networking(error):
            return "Networking error: \(error)"
        case let .response(errorResponse, status):
            if let status {
                return "Response error: \(errorResponse) with status \(status)"
            }
            return "Response error: \(errorResponse)"
        case .cancelled:
            return "Cancelled"
        case .invalidSession:
            return "Invalid session"
        case let .decoding(data, error):
            guard let string = String(data: data, encoding: .utf8) else {
                return localizedDescription
            }
            
            if let error {
                return "Unable to decode: \(string)\nError: \(error)"
            }
            
            return "Unable to decode: \(string)"
        }
    }
}
