//
//  PaginatedResponse.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

internal struct PagedResponse<Value> {
    let items: [Value]
    let nextLocation: PageLocation
}
