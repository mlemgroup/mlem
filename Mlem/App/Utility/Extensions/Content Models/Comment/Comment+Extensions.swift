//
//  Comment+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-21.
//

import MlemMiddleware

extension Comment {
    func shouldShowLoadingSymbol(for barConfiguration: CommentBarConfiguration? = nil) -> Bool {
        // TODO: NOW really?
        false
    }
    
    var shouldHideInFeed: Bool {
        (creator.value_?.shouldHideInFeed ?? false) || purged
    }
    
    var isOwnComment: Bool { creatorId == api.myPerson?.id }
}
