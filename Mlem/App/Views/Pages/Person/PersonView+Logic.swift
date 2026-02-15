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
            guard let feedLoader else { return }
            do {
                if feedLoader.loadingState == .initial {
                    try await feedLoader.loadMoreItems()
                }
            } catch {
                // This is OK to silence because the feed loader will fail when
                // it appears if this fails, and will show an ErrorView.
                handleError(error, silent: true)
            }
        }
    }
    
    func tabs(person: Person) -> [Tab] {
        var output: [Tab] = [.overview, .posts, .comments]
        if !(person.moderatedCommunities.value?.isEmpty ?? true) {
            output.append(.communities)
        }
        return output
    }
    
    func logVisit(_ person: Person) {
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
