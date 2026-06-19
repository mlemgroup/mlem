//
//  PageInfo.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

public struct PageInfo: Hashable {
    public var cursor: PageCursor
    public let limit: Int

    public init(cursor: PageCursor, limit: Int) {
        self.cursor = cursor
        self.limit = limit
    }
}
