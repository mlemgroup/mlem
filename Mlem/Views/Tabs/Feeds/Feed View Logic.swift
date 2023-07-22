//
//  Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation

extension FeedView {
    
    // MARK: feed loading
    
    func initFeed() async {
        if postTracker.items.isEmpty {
            print("Post tracker is empty")
            await loadFeed()
        } else {
            print("Post tracker is not empty")
        }
    }
    
    func loadFeed() async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await postTracker.loadNextPage(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: { postView in
                    !postView.post.name.contains(filtersTracker.filteredKeywords)
                }
            )
        } catch {
            handle(error)
        }
    }
    
    func refreshFeed() async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await postTracker.refresh(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: { postView in
                    !postView.post.name.contains(filtersTracker.filteredKeywords)
                }
            )
        } catch {
            handle(error)
        }
    }
    
    private func handle(_ error: Error) {
        let title: String?
        let errorMessage: String?

        switch error {
        case APIClientError.networking:
            guard postTracker.items.isEmpty else {
                return
            }

            title = "Unable to connect to Lemmy"
            errorMessage = "Please check your internet connection and try again"
        default:
            title = nil
            errorMessage = nil
        }

        appState.contextualError = .init(
            title: title,
            message: errorMessage,
            underlyingError: error
        )
    }
}
