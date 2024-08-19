//
//  PersonView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation

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
}
