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
    
    private let commentsIndex: DraftsIndex
    
    init() {
        self.commentsIndex = PersistenceRepository.liveValue.loadCommentDraftsIndex() ?? .init()
    }
    
    public func getAvailableCommentDraftsForTarget(_ target: ActorIdentifier) -> [DraftMetadata] {
        commentsIndex.retrieveByTarget(target) ?? .init()
    }
    
    public func getCommentDraft(_ draftId: UUID) -> CommentDraft? {
        persistenceRepository.loadCommentDraft(draftId)
    }
    
    public func saveCommentDraft(_ commentDraft: CommentDraft) async throws {
        commentsIndex.index(commentDraft.metadata)
        try await persistenceRepository.saveCommentDraft(commentDraft)
        try await persistenceRepository.saveCommentDraftsIndex(commentsIndex)
    }
    
    public func deleteCommentDraft(_ draftId: UUID) async throws {
        commentsIndex.deindex(draftId)
        try persistenceRepository.deleteCommentDraft(draftId)
        try await persistenceRepository.saveCommentDraftsIndex(commentsIndex)
    }
}
