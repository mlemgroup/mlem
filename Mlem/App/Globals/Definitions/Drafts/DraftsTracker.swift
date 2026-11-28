//
//  DraftsTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-25.
//

import Observation
import Dependencies
import MlemMiddleware
import Foundation

class DraftsTracker {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    
    private let commentsIndex: DraftsIndex<CommentDraft>
    
    init() {
        self.commentsIndex = PersistenceRepository.liveValue.loadCommentDraftsIndex() ?? .init()
    }
    
    public func getAvailableCommentDraftsForTarget(_ target: ActorIdentifier) -> [CommentDraft] {
        commentsIndex.retrieveByTarget(target) ?? .init()
    }
    
    public func saveCommentsIndex() async throws {
        try await persistenceRepository.saveCommentDraftsIndex(commentsIndex)
    }
    
    public func createCommentDraft(
        authorActorId: ActorIdentifier,
        targetActorId: ActorIdentifier,
        language: Locale.Language?,
        text: String
    ) async throws -> CommentDraft {
        let draft: CommentDraft = .init(
            index: commentsIndex,
            authorActorId: authorActorId,
            targetActorId: targetActorId,
            language: language,
            text: text)
        try await persistenceRepository.saveCommentDraftsIndex(commentsIndex)
        return draft
    }
    
    public func deleteCommentDraft(_ draftId: UUID) async throws {
        commentsIndex.deindex(draftId)
        try await persistenceRepository.saveCommentDraftsIndex(commentsIndex)
    }
}
