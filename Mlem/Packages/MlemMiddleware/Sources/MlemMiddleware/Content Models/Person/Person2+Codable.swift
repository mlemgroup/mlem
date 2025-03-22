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
        let apiPersonView: ApiPersonView
    }
    
    internal var apiPersonView: ApiPersonView {
        .init(
            person: person1.apiPerson,
            counts: .init(
                id: nil,
                personId: id,
                postCount: postCount,
                postScore: nil,
                commentCount: commentCount,
                commentScore: nil
            ),
            isAdmin: isAdmin
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
