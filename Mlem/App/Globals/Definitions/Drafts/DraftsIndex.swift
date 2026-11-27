//
//  DraftsIndex.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-25.
//

import Foundation
import MlemMiddleware

struct DraftMetadata: Codable {
    let id: UUID
    let touched: Date
    let target: ActorIdentifier
    let author: ActorIdentifier
}

class DraftsIndex: Codable {
    private var idIndex: [UUID: DraftMetadata]
    private var targetIndex: [ActorIdentifier: [DraftMetadata]]
    private var authorIndex: [ActorIdentifier: [DraftMetadata]]
    
    public init() {
        self.idIndex = .init()
        self.targetIndex = .init()
        self.authorIndex = .init()
    }
    
    public static var persistenceKey: String = "index"
    
    // MARK: Update
    
    /// Inserts or updates the given DraftMetadata
    func index(_ draftMetadata: DraftMetadata) {
        if let existing = idIndex[draftMetadata.id] {
            // if already indexed, remove from all indices that are now stale
            if existing.target != draftMetadata.target {
                targetIndex[draftMetadata.target]?.removeAll { $0.id == draftMetadata.id }
                targetIndex[draftMetadata.target]?.append(draftMetadata)
            }
            if existing.author != draftMetadata.author {
                authorIndex[draftMetadata.author]?.removeAll { $0.id == draftMetadata.id }
                authorIndex[draftMetadata.author]?.append(draftMetadata)
            }
        } else {
            // if not already indexed, just create entries
            targetIndex[draftMetadata.target, default: .init()].append(draftMetadata)
            authorIndex[draftMetadata.author, default: .init()].append(draftMetadata)
        }
        // idIndex overwritten in all cases
        idIndex[draftMetadata.id] = draftMetadata
    }
    
    /// Removes the given DraftMetadata from all indices
    func deindex(_ id: UUID) {
        guard let draftMetadata = retrieveById(id) else { return }
        idIndex.removeValue(forKey: id)
        targetIndex[draftMetadata.target]?.removeAll { $0.id == id }
        authorIndex[draftMetadata.author]?.removeAll { $0.id == id }
    }
    
    // MARK: Retrieval
    
    func retrieveById(_ id: UUID) -> DraftMetadata? {
        idIndex[id]
    }
    
    func retrieveByTarget(_ target: ActorIdentifier) -> [DraftMetadata]? {
        targetIndex[target]
    }
    
    func retrieveByAuthor(_ author: ActorIdentifier) -> [DraftMetadata]? {
        authorIndex[author]
    }
    
    // MARK: Coding
    // only the idIndex is directly encoded; other indices are constructed at runtime from it
    
    enum CodingKeys: String, CodingKey {
        case idIndex
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.idIndex = try values.decode([UUID: DraftMetadata].self, forKey: .idIndex)
        
        self.targetIndex = .init()
        self.authorIndex = .init()
        self.idIndex.values.forEach { draftMetadata in
            self.targetIndex[draftMetadata.target, default: .init()].append(draftMetadata)
            self.authorIndex[draftMetadata.author, default: .init()].append(draftMetadata)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idIndex, forKey: .idIndex)
    }
}
