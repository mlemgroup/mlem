//
//  Person2+Codable.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-03.
//

import Foundation

public extension Person2 {
    struct CodedData: Codable {
        let apiUrl: URL
        let apiMyPersonId: Int?
        let apiPersonView: LemmyPersonView
    }
    
    internal var apiPersonView: LemmyPersonView {
        .init(
            person: person1.apiPerson,
            counts: .init(
                personId: id,
                postCount: postCount,
                commentCount: commentCount
            ),
            isAdmin: isAdmin,
            personActions: nil,
            creatorBanned: nil
        )
    }
    
    func codedData() async throws -> CodedData {
        try await .init(
            apiUrl: api.baseUrl,
            apiMyPersonId: api.myPersonId,
            apiPersonView: apiPersonView
        )
    }
}
