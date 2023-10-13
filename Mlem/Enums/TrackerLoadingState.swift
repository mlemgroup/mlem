//
//  TrackerLoadingState.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-12.
//

import Foundation

/// Enum of possible loading states that a standard tracker can be in.
/// - idle: not currently loading, but more posts available to load
/// - loading: currently loading more posts
/// - done: no more posts available to load
enum TrackerLoadingState {
    case idle, loading, done
}
