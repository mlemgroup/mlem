//
//  PagedResponse+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

import Foundation

extension PagedResponse {
    init<T>(from response: LemmyPagedResponse<T>, converter: (T) -> Value) {

        let nextLocation: PageLocation

        if let nextPage = response.nextPage {
            nextLocation = .at(.init(cursorType: .cursorString(nextPage)))
        } else {
            nextLocation = .end
        }

        self.init(items: response.items.map(converter), nextLocation: nextLocation)
    }

    // On Lemmy v3, some requests use the page number system and others
    // use the cursor system. This method decodes both cases.
    //
    static func fromLemmyV3(
        items: [Value],
        limit: Int,
        inputCursor: PageCursor,
        outputCursor outputCursor_: String?
    ) throws(PageCursor.PageCursorError) -> Self {
        let outputCursor = outputCursor_.map { PageCursor(cursorType: .cursorString($0)) }

        let nextLocation: PageLocation

        if let outputCursor {
            // On Lemmy v3, getting an identical cursor signals the end of the feed.
            if outputCursor != inputCursor {
                nextLocation = .at(outputCursor)
            } else {
                nextLocation = .end
            }
        } else if items.count < limit {
            nextLocation = .end
        } else {
            let cursor = try inputCursor.stepForward()
            nextLocation = .at(cursor)
        } 

        return .init(items: items, nextLocation: nextLocation)
    }
}
