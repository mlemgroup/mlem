//
//  TopPeopleListView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-15.
//

import MlemMiddleware
import SwiftUI

struct TopPeopleListView: View {
    @Environment(AppState.self) var appState
    
    @State var personLoader: PersonFeedLoader?

    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: 0) {
                if let personLoader {
                    SearchResultsView(results: personLoader.items) { person in
                        PersonListRow(
                            person,
                            readout: .postsAndComments,
                            visitContext: .other
                        )
                        .onAppear {
                            do {
                                try personLoader.loadIfThreshold(person)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                    EndOfFeedView(feedLoader: personLoader, viewType: .hobbit)
                }
            }
            .animation(.easeOut(duration: 0.1), value: personLoader?.items.isEmpty)
            .task {
                do {
                    personLoader = .init(api: appState.firstApi)
                    try await personLoader?.refresh(listing: .all)
                } catch {
                    handleError(error)
                }
            }
        }
        .background(.themedGroupedBackground)
        .navigationTitle("Users")
    }
}
