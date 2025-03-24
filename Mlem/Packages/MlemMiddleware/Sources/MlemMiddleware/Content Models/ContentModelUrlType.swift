//
//  ContentModelUrlType.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-26.
//

import Foundation

public enum ContentModelUrlType: CaseIterable {
    /// Refers to the instance that this entity originally came from.
    case host
    /// Refers to the instance that provided this entity (e.g. the `ApiClient` attached to the entity).
    case provider
}
