//
//  MultiTrackerLoadingState.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-12.
//

import Foundation

/// Enum of possible loading states that a multi-tracker can be in.
/// - idle: not currently loading anything, but more items available to load
/// - waiting: waiting for a child tracker before continuing to load
/// - loading: currently loading items
/// - done: no more items to load
enum MultiTrackerLoadingState {
    case idle, waiting, loading, done
}
