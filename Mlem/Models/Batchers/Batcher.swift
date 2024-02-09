//
//  Batcher.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-08.
//

import Foundation

/// Protocol for classes that can be used to accumulate and dispatch batch requests
/// Right now it's only used for marking posts as read on scroll, but I can see other potential use cases (e.g., marking inbox items as read on scroll) at which point the protocol will become useful for its affiliated view modifier
protocol Batcher {
    /// True when this batcher is enabled. Required because batching is API-dependent and not supported on older instances
    var enabled: Bool { get }
    
    /// Call when site version is resolved to determine enabled status
    func resolveSiteVersion(to siteVersion: SiteVersion)
    
    /// Execute all pending requests and start a new batch
    func flush() async
}
