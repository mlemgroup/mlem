//
//  InstanceCommunityListView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-09.
//  

import MlemMiddleware
import SwiftUI

struct InstanceCommunityListView: View {
    let communityLoader: CommunityFeedLoader

    @Binding var errorDetails: ErrorDetails?

    var body: some View {
        LazyVStack(spacing: 0) {
            if let errorDetails {
                ErrorView(errorDetails)
                    .padding(.top, 30)
            } else {
                SearchResultsView(results: communityLoader.items) { community in
                    CommunityListRow(
                        community,
                        readout: .subscribers,
                        visitContext: .other
                    )
                    .onAppear {
                        do {
                            try communityLoader.loadIfThreshold(community)
                        } catch {
                            handleError(error)
                        }
                    }
                }
                EndOfFeedView(feedLoader: communityLoader, viewType: .hobbit)
            }
        }
        .animation(.easeOut(duration: 0.1), value: communityLoader.items.isEmpty)
        .task {
            print(errorDetails)
            if errorDetails == nil {
                await refresh()
            }
        }
    }

    func refresh() async {
        do {
            if communityLoader.loadingState == .initial {
                try await communityLoader.refresh(listing: .local)
            }
            self.errorDetails = nil
        } catch {
            var errorDetails = handleErrorWithDetails(error)

            errorDetails?.refresh = {
                await refresh()
                return true
            }

            if case let ApiClientError.response(response, _) = error {
                if response.instanceIsPrivate {
                    errorDetails?.title = "Instance is private"
                    errorDetails?.body = "You cannot view the communities of a private instance."
                    errorDetails?.icon = .lemmy.private
                    errorDetails?.refresh = nil
                }
            }

            self.errorDetails = errorDetails
        }
    }
}
