//
//  LoadingState.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-12.
//
import Foundation

/// Enum of possible loading states that a tracker can be in.
/// - idle: not currently loading, but more items available to load
/// - loading: currently loading more items
/// - done: no more items available to load
enum LoadingState {
    case idle, loading, done
}
