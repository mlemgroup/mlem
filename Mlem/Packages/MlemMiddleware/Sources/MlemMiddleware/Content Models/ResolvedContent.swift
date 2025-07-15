//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public enum ResolvedContent {
    case comment(Comment2Snapshot)
    case post(Post2Snapshot)
    case community(Community2Snapshot)
    case person(Person2Snapshot)
}
