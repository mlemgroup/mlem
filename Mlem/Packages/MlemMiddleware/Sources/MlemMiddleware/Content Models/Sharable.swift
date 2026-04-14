//
//  Sharable.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-09.
//

import Foundation

public protocol Sharable: ActorIdentifiable, Hashable {
    var host: String { get }
    
    func url() -> URL
}
