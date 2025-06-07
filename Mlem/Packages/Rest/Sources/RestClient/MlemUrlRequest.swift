//
//  MlemUrlRequest.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-03-12.
//

import Foundation

public func mlemUrlRequest(url: URL) -> URLRequest {
    var url = url
    // .gifv is secretly just mp4; replacing the extension here ensures it is picked up by the NukeVideo decoder
    if url.pathExtension == "gifv" {
        if let fixedUrl: URL = .init(string: url.absoluteString.replacingOccurrences(of: ".gifv", with: ".mp4")) {
            url = fixedUrl
        } else {
            assertionFailure("Could not create fixed URL for \(url)")
        }
    }
    var ret = URLRequest(url: url)
    ret.addValue("MlemUserAgent", forHTTPHeaderField: "User-Agent")
    return ret
}
