//
//  ApiRegistrationApplicationView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

extension ApiRegistrationApplicationView: CacheIdentifiable {
    public var cacheId: Int { registrationApplication.id }
}
