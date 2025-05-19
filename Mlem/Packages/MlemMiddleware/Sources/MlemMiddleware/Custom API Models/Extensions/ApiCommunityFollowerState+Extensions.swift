//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-05.
//

import Foundation

public extension ApiCommunityFollowerState {
    var isSubscribed: Bool { self == .accepted }
}
