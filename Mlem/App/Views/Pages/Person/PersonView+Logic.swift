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
                if feedLoader.loadingState == .initial {
                    try await feedLoader.loadMoreItems()
                }
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
    
    func logVisit(_ person: Person2) {
        guard let visitContext else { return }
        if let session = (appState.firstSession as? UserSession), let visitHistory = session.visitHistory {
            guard session.api === person.api else { return }
            visitHistory.addPerson(person, context: visitContext)
            Task(priority: .background) {
                try await session.saveVisitHistory()
            }
        }
    }
}
