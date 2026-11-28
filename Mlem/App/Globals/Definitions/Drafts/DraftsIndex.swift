//
//  DraftsIndex.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-25.
//

import Foundation
import MlemMiddleware
import Observation

protocol DraftProviding: AnyObject, Codable {
    var draftId: UUID { get }
    var touched: Date { get }
    var targetActorId: ActorIdentifier { get }
    var authorActorId: ActorIdentifier { get }
    
    /// Required for decoding init, should not be called outside of DraftsIndex
    func setIndex(to newIndex: DraftsIndex<Self>)
    
    /// Resolves actorIds to relevant entities using the account affiliated with authorActorId
    func resolve() async throws
}

@Observable
final class CommentDraft: DraftProviding {
    enum ResolutionState {
        case notStarted, resolving, succeeded, failed
    }
    
    private(set) weak var index: DraftsIndex<CommentDraft>?
    
    let draftId: UUID
    private(set) var touched: Date
    private(set) var authorActorId: ActorIdentifier
    let targetActorId: ActorIdentifier
    private(set) var language: Locale.Language?
    private(set) var text: String
    
    private(set) var author: UserAccount?
    private(set) var targetComment: Comment?
    private(set) var targetPost: Post?
    
    private(set) var resolved: ResolutionState = .notStarted
    
    public init(
        index: DraftsIndex<CommentDraft>,
        authorActorId: ActorIdentifier,
        targetActorId: ActorIdentifier,
        language: Locale.Language?,
        text: String) {
            self.index = index
            self.draftId = UUID()
            self.touched = .now
            self.authorActorId = authorActorId
            self.targetActorId = targetActorId
            self.language = language
            self.text = text
            
            index.index(self)
        }
    
    func setIndex(to newIndex: DraftsIndex<CommentDraft>) {
        guard index == nil else {
            assertionFailure("Cannot reassign index")
            return
        }
        self.index = newIndex
    }
    
    func resolve() async throws {
        resolved = .resolving
        
        guard let author = AccountsTracker.main.userAccounts.first(where: { $0.actorId == authorActorId }) else {
            assertionFailure("Failed to find author in user accounts")
            resolved = .failed
            return
        }
        self.author = author
        
        let target = try await author.api.resolve(url: targetActorId.url)
        if let comment = target as? Comment {
            self.targetComment = comment
        } else if let post = target as? Post {
            self.targetPost = post
        } else {
            assertionFailure("Target for comment draft failed to resolve to Comment or Post")
            resolved = .failed
            return
        }
        
        resolved = .succeeded
    }
    
    func update(
        author: UserAccount,
        language: Locale.Language?,
        text: String
    ) async throws {
        guard let index else {
            assertionFailure("Cannot update without index")
            return
        }

        let previousAuthor: ActorIdentifier? = author.actorId != self.authorActorId ? self.authorActorId : nil

        self.touched = .now
        self.author = author
        self.authorActorId = author.actorId
        self.language = language
        self.text = text

        index.reindex(self, previousTarget: nil, previousAuthor: previousAuthor)
    }
    
    // MARK: Coding
    // None of the resolved fields are encoded
    
    enum CodingKeys: String, CodingKey {
        case draftId, touched, authorActorId, targetActorId, language, text
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.draftId = try values.decode(UUID.self, forKey: .draftId)
        self.touched = try values.decode(Date.self, forKey: .touched)
        self.authorActorId = try values.decode(ActorIdentifier.self, forKey: .authorActorId)
        self.targetActorId = try values.decode(ActorIdentifier.self, forKey: .targetActorId)
        self.language = try values.decode(Locale.Language?.self, forKey: .language)
        self.text = try values.decode(String.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(draftId, forKey: .draftId)
        try container.encode(touched, forKey: .touched)
        try container.encode(authorActorId, forKey: .authorActorId)
        try container.encode(targetActorId, forKey: .targetActorId)
        try container.encode(language, forKey: .language)
        try container.encode(text, forKey: .text)
    }
}

class DraftsIndex<Draft: DraftProviding>: Codable {
    private var idIndex: [UUID: Draft]
    private var targetIndex: [ActorIdentifier: [Draft]]
    private var authorIndex: [ActorIdentifier: [Draft]]
    
    public init() {
        self.idIndex = .init()
        self.targetIndex = .init()
        self.authorIndex = .init()
    }
    
    public let persistenceKey: String = "index"
    
    // MARK: Update
    
    /// Inserts a new draft into the index
    func index(_ draft: Draft) {
        guard idIndex[draft.draftId] == nil else {
            assertionFailure("Cannot call index() with existing draft")
            return
        }
        
        // create fresh entries
        idIndex[draft.draftId] = draft
        targetIndex[draft.targetActorId, default: .init()].append(draft)
        authorIndex[draft.authorActorId, default: .init()].append(draft)
    }
    
    /// Re-indexes the given draft. If any previous... field is provided, assumes that field has changed and
    /// re-indexes accordingly. If a previous... field is nil, no action will be taken for the relevant indices.
    func reindex(
        _ draft: Draft,
        previousTarget: ActorIdentifier?,
        previousAuthor: ActorIdentifier?) {
            if let previousTarget {
                assert(previousTarget != draft.targetActorId, "previousTarget provided but target unchanged")
                targetIndex[previousTarget]?.removeAll(where: { $0.targetActorId == previousTarget })
                targetIndex[draft.targetActorId, default: .init()].append(draft)
            }
            if let previousAuthor {
                assert(previousAuthor != draft.authorActorId, "previousAuthor provided but target unchanged")
                authorIndex[previousAuthor]?.removeAll(where: { $0.authorActorId == previousAuthor })
                authorIndex[draft.authorActorId, default: .init()].append(draft)
            }
        }
    
    /// Removes the given DraftMetadata from all indices
    func deindex(_ draftId: UUID) {
        guard let draftMetadata = retrieveById(draftId) else { return }
        idIndex.removeValue(forKey: draftId)
        targetIndex[draftMetadata.targetActorId]?.removeAll { $0.draftId == draftId }
        authorIndex[draftMetadata.authorActorId]?.removeAll { $0.draftId == draftId }
    }
    
    // MARK: Retrieval
    
    func retrieveById(_ draftId: UUID) -> Draft? {
        idIndex[draftId]
    }
    
    func retrieveByTarget(_ target: ActorIdentifier) -> [Draft]? {
        targetIndex[target]
    }
    
    func retrieveByAuthor(_ author: ActorIdentifier) -> [Draft]? {
        authorIndex[author]
    }
    
    // MARK: Coding
    // only the idIndex is directly encoded; other indices are constructed at runtime from it
    
    enum CodingKeys: String, CodingKey {
        case idIndex
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idIndex = try values.decode([UUID: Draft].self, forKey: .idIndex)
        
        self.targetIndex = .init()
        self.authorIndex = .init()
        self.idIndex.values.forEach { draft in
            draft.setIndex(to: self)
            self.targetIndex[draft.targetActorId, default: .init()].append(draft)
            self.authorIndex[draft.authorActorId, default: .init()].append(draft)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idIndex, forKey: .idIndex)
    }
}
