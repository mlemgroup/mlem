//
//  CommentSnapshotProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-08-12.
//

public  protocol CommentSnapshotProviding {
    /// Combines this snapshot with the given snapshot, returning the highest possible tier snapshot. Prefers this snapshot's values.
    func merge(with snapshot: any CommentSnapshotProviding) -> any CommentSnapshotProviding
}
