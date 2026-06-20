//
//  PieFedErrorResponse.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-01.
//

import Foundation

// https://codeberg.org/rimu/pyfedi/src/commit/6378bd77b84681d4e646860183598bb7a5bf17be/app/api/alpha/__init__.py#L91

public struct PieFedErrorResponse: Decodable, CustomStringConvertible {
    public let code: Int
    public let status: String // String version of the `code`, e.g. "Bad Request"

    public let message: String
    
    public var description: String { message }
}
