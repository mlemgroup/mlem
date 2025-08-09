//
//  PostSnapshotProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

public  protocol PostSnapshotProviding {
    /// Combines this snapshot with the given snapshot, returning the highest possible tier snapshot. Prefers this snapshot's values.
    func merge(with snapshot: any PostSnapshotProviding) -> any PostSnapshotProviding
}
