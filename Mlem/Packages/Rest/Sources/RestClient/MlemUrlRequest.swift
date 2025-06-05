//
//  MlemUrlRequest.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-03-12.
//

import Foundation

public func mlemUrlRequest(url: URL) -> URLRequest {
    var ret = URLRequest(url: url)
    ret.addValue("MlemUserAgent", forHTTPHeaderField: "User-Agent")
    return ret
}
