//
//  URLQueryItemEncoder.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-20.
//

import Foundation

public enum URLQueryItemEncoder {
    public static func encode(
        _ value: some Encodable,
        convertToSnakeCase: Bool,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws(URLQueryItemEncoderError) -> [URLQueryItem] {
        let encoder = InternalURLQueryItemEncoder(
            userInfo: userInfo,
            settings: .init(convertToSnakeCase: convertToSnakeCase)
        )
        do {
            try value.encode(to: encoder)
        } catch {
            if let error = error as? URLQueryItemEncoderError {
                throw error
            }
            assertionFailure()
            throw .unknown
        }
        return encoder.queryParams
    }
}

public enum URLQueryItemEncoderError: Error {
    case nestedContainersUnsupported
    case singleValueContainerUnsupported
    case unkeyedContainerUnsupported
    case unknown // Should never be thrown
}
