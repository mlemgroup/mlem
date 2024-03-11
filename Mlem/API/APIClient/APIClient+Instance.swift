//
//  APIClient+Instance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

extension APIClient {
    func getModlog() async throws -> [AnyModlogEntry] {
        // TODO: params
        let request = try GetModlogRequest(
            session: session,
            modPersonId: nil,
            communityId: nil,
            page: nil,
            limit: nil,
            type_: nil,
            otherPersonId: nil
        )
        
        let response = try await perform(request: request)
        
        return response.removedPosts.map { AnyModlogEntry(wrappedValue: $0) }
    }
}
