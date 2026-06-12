//
//  PagedResponse+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-12.
//

import Foundation

extension PagedResponse {
    static func fromPieFed(
        pageInfo info: PageInfo,
        items: [Value],
    ) throws(PageCursor.PageCursorError) -> Self {
        let nextLocation: PageLocation

        if items.count < info.limit {
            nextLocation = .end
        } else {
            let cursor = try info.cursor.stepForward()
            nextLocation = .at(cursor)
        } 

        return .init(items: items, nextLocation: nextLocation)
    }
}
