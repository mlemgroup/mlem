//
//  Community Search Field.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI
import Combine

struct CommunitySearchField: View {

    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker

    @EnvironmentObject var appState: AppState

    @FocusState.Binding var isSearchFieldFocused: Bool

    @Binding var searchText: String

    @State var account: SavedAccount

    @State private var debouncedTextReadyForSearching: String = ""
    
    let searchTextPublisher: PassthroughSubject = PassthroughSubject<String, Never>()

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                TextField("Community…", text: $searchText)
                    .focused($isSearchFieldFocused)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                    .onChange(of: searchText) { searchText in
                        searchTextPublisher.send(searchText)
                        print("Search text: \(searchText)")
                    }
                    .onReceive(
                        searchTextPublisher
                            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                    ) { debouncedText in
                        debouncedTextReadyForSearching = debouncedText
                        print("Debounced text: \(debouncedTextReadyForSearching)")
                    }
                    .onChange(of: debouncedTextReadyForSearching) { searchText in
                        Task(priority: .userInitiated) {
                            do {
                                let request = SearchRequest(
                                    account: account,
                                    query: searchText,
                                    searchType: .communities,
                                    sortOption: .topAll,
                                    listingType: .all
                                )

                                let response = try await APIClient().perform(request: request)
                                communitySearchResultsTracker.foundCommunities = response.communities
                            } catch {
                                appState.contextualError = .init(underlyingError: error)
                            }
                        }
                    }
                    .onAppear {
                    isSearchFieldFocused.toggle()
                }
            }
        }
    }
}
