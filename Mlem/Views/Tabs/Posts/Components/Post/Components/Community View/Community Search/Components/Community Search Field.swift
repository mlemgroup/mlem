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
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    @Binding var searchText: String
    
    @State var account: SavedAccount
    
    @State private var debouncedTextReadyForSearching: String = ""
    
    let searchTextPublisher: PassthroughSubject = PassthroughSubject<String, Never>()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack
            {
                Spacer()
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
                            let searchResponse: String = try! await sendCommand(maintainOpenConnection: true, instanceAddress: account.instanceLink, command: """
{"op": "Search", "data": {"type_": "Communities", "sort": "TopAll", "listing_type": "All", "q": "\(searchText)"}}
""")
                            print("Search response: \(searchResponse)")
                            
                            communitySearchResultsTracker.foundCommunities = try! parseCommunities(communityResponse: searchResponse, instanceLink: account.instanceLink)
                        }
                    }
                Spacer()
            }
        }
    }
}

