//
//  ApiRegistrationApplication+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

extension ApiRegistrationApplication: CacheIdentifiable {
    public var cacheId: Int { id }
}
