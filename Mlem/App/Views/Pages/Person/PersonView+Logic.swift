//
//  PersonView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import MlemMiddleware

extension PersonView {
    func preheatFeedLoader() {
        Task {
            guard let feedLoader else {
                assertionFailure("No feedLoader found!")
                return
            }
            do {
                try await feedLoader.loadMoreItems()
            } catch {
                handleError(error)
            }
        }
    }
    
    func tabs(person: any Person3Providing) -> [Tab] {
        var output: [Tab] = [.overview, .posts, .comments]
        if !person.moderatedCommunities.isEmpty {
            output.append(.communities)
        }
        return output
    }
}
