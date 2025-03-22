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

public enum ApiClientError: Error {
    case encoding(Error)
    case networking(Error)
    case response(ApiErrorResponse, Int?)
    case cancelled
    case notLoggedIn
    case invalidSession(ApiClient)
    case decoding(Data, Error?)
    case insufficientPermissions
    /// Thrown when a `false` value of `SuccessResponse` is returned
    case unsuccessful
    case unsupportedLemmyVersion
    case noEntityFound
    case invalidInput
    case imageTooLarge
    case mismatchingUrl
    case mismatchingPersonId
    case mismatchingToken
    case noToken
}

extension ApiClientError: CustomStringConvertible {
    public var description: String {
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
            return "Invalid session. There is a token applied to the ApiClient, but it has expired."
        case .notLoggedIn:
            return "Tried to perform an action that requires authentication on a guest ApiClient."
        case .imageTooLarge:
            return "Image too large"
        case let .decoding(data, error):
            guard let string = String(data: data, encoding: .utf8) else {
                return localizedDescription
            }
            
            if let error {
                return "Unable to decode: \(string)\nError: \(error)"
            }
            
            return "Unable to decode: \(string)"
        case .unsuccessful:
            return "Operation was unsuccessful."
        case .unsupportedLemmyVersion:
            return "This version of Lemmy doesn't support that operation."
        case .noEntityFound:
            return "No entity returned in response."
        case .invalidInput:
            return "Invalid input"
        case .mismatchingUrl:
            return "URL of the decoding ApiClient doesn't match the URL of the ApiClient that encoded the data"
        case .mismatchingPersonId:
            return "Person ID of the decoding ApiClient doesn't match the Person ID of the ApiClient that encoded the data"
        case .mismatchingToken:
            return "A valid token was assigned to an ApiClient for the wrong account."
        case .noToken:
            return "A call was made to an ApiClient that doesn't have a token yet."
        }
    }
}
