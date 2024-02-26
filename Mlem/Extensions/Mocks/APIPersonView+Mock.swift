//
//  APIPersonView+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APIPersonView {
    static func mock(
        person: APIPerson = .mock(),
        counts: APIPersonAggregates = .mock(),
        isAdmin: Bool = false
    ) -> APIPersonView {
        .init(
            person: person,
            counts: counts,
            isAdmin: isAdmin
        )
    }
}
