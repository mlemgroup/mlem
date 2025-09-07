//
//  FeedLoadingState.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-12.
//
import Foundation

/// Enum of possible loading states that a loader can be in.
/// - idle: not currently loading, but more items available to load
/// - loading: currently loading more items
/// - done: no more items available to load
public enum LoadingState: Hashable {
    case idle, loading, done
}

public enum FeedLoadingState: Hashable {
    case initial, idle, loading, done

    public init(from loadingState: LoadingState) {
        self = switch loadingState {
        case .idle: .idle
        case .loading: .loading
        case .done: .done
        }
    }
}
