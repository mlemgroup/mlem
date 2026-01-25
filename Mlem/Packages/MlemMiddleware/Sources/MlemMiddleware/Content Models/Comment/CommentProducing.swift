//
//  CommentProducing.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-24.
//

/// Protocol describing things that can be resolved to a comment
public protocol CommentResolvable {
    func asComment() async throws -> Comment
}
