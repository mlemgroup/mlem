//
//  CommentDraft.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-25.
//

import Observation
import MlemMiddleware
import Foundation

public struct CommentDraft: Codable {
    let id: UUID
    let author: ActorIdentifier
    let target: ActorIdentifier
    let language: Locale.Language?
    let text: String
    
    var metadata: DraftMetadata {
        .init(draftId: id, touched: .now, target: target, author: author)
    }
}
