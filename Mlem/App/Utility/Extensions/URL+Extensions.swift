//
//  URL+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-20.
//

import Foundation

extension URL {
    /// Path extension of this URL, taking into account image proxy behavior
    var proxyAwarePathExtension: String? {
        var ret = pathExtension
        
        // image proxies that use url query param don't have pathExtension so we extract it from the embedded url
        if ret.isEmpty,
           let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let baseUrlString = queryItems.first(where: { $0.name == "url" })?.value,
           let baseUrl = URL(string: baseUrlString) {
            ret = baseUrl.pathExtension
        }
        
        return ret.isEmpty ? nil : ret
    }
}
