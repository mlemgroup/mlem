//
//  CommentCaches.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public enum AnyCommentSnapshot: CacheIdentifiable {
    case comment1(Comment1Snapshot)
    case comment2(Comment2Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .comment1(snapshot): snapshot.cacheId
        case let .comment2(snapshot): snapshot.cacheId
        }
    }
}

class CommentCache: ApiTypeBackedCache<Comment, AnyCommentSnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyCommentSnapshot) -> Comment {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Comment, with apiType: AnyCommentSnapshot, semaphore: UInt? = nil) {
        // this ensures that high-tier data is available where expected, but uses softUpdate to avoid overwriting
        // potentially more recent data
        item.softUpdate(with: .init(api: item.api, snapshot: apiType))
    }
}
