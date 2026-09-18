//
//  URLSessionConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-07.
//

import Foundation

extension URLSessionConfiguration {
    static var mlem: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": "MlemUserAgent"]
        return configuration
    }
}
