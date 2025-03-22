//
//  Sharable.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-09.
//

import Foundation

public protocol Sharable: ContentIdentifiable, ActorIdentifiable, Resolvable {
    func url() -> URL
}
