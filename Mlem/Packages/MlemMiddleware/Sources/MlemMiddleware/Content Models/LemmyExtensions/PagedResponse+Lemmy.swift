//
//  PagedResponse+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

import Foundation

extension PagedResponse {
    init<T, E>(
        from response: LemmyPagedResponse<T>,
        converter: (T) throws(E) -> Value
    ) throws(E) {

        let nextLocation: PageLocation

        if let nextPage = response.nextPage {
            nextLocation = .at(.init(cursorType: .cursorString(nextPage)))
        } else {
            nextLocation = .end
        }

        try self.init(items: response.items.map(converter), nextLocation: nextLocation)
    }

    static func compact<T, E>(
        from response: LemmyPagedResponse<T>,
        converter: (T) throws(E) -> Value?
    ) throws(E) -> Self {

        let nextLocation: PageLocation

        if let nextPage = response.nextPage {
            nextLocation = .at(.init(cursorType: .cursorString(nextPage)))
        } else {
            nextLocation = .end
        }

        // Swift compiler doesn't like direct `.compactMap` for some reason
        let items = try response.items
            .map(converter)
            .compactMap { $0 }
        
        return .init(items: items, nextLocation: nextLocation)
    }

    // On Lemmy v3, some requests use the page number system and others
    // use the cursor system. This method decodes both cases.
    //
    static func fromLemmyV3(
        pageInfo info: PageInfo,
        items: [Value],
        nextCursor nextCursor_: String?
    ) throws(PageCursor.PageCursorError) -> Self {
        let nextCursor = nextCursor_.map { PageCursor(cursorType: .cursorString($0)) }

        let nextLocation: PageLocation

        if let nextCursor {
            // On Lemmy v3, getting an identical cursor signals the end of the feed.
            if nextCursor != info.cursor {
                nextLocation = .at(nextCursor)
            } else {
                nextLocation = .end
            }
        } else if items.count < info.limit {
            nextLocation = .end
        } else {
            let cursor = try info.cursor.stepForward()
            nextLocation = .at(cursor)
        } 

        return .init(items: items, nextLocation: nextLocation)
    }
}
