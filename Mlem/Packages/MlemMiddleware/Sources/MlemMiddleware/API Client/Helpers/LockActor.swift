//
//  LockActor.swift
//  Mlem
//
//  Created by Sjmarf on 2026-05-29.
//

actor LockActor {
    func withLock<T>(_ body: () async throws -> T) async rethrows -> T {
        try await body()
    }
}
