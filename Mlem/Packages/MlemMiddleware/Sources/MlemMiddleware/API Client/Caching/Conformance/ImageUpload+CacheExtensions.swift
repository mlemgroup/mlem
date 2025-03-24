//
//  ImageUpload+CacheExtensions.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

extension ImageUpload1: CacheIdentifiable {
    public var cacheId: Int { alias.hashValue }
}
