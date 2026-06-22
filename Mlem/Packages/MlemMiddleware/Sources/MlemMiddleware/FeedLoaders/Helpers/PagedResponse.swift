//
//  PaginatedResponse.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

public struct PagedResponse<Value> {
    public let items: [Value]
    public let nextLocation: PageLocation

    public init(items: [Value], nextLocation: PageLocation) {
        self.items = items
        self.nextLocation = nextLocation
    }
}
