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
                            let searchResponse: String = try! await sendGetCommand(account: account, endpoint: "search", parameters: [
                                URLQueryItem(name: "type_", value: "Communities"),
                                URLQueryItem(name: "sort", value: "TopAll"),
                                URLQueryItem(name: "listing_type", value: "All"),
                                URLQueryItem(name: "q", value: searchText)
                            ])
                            
                            print("Search response: \(searchResponse)")
                            
                            communitySearchResultsTracker.foundCommunities = try! parseCommunities(communityResponse: searchResponse, instanceLink: account.instanceLink)
                        }
                    }
                    .onAppear
                {
                    isSearchFieldFocused.toggle()
                }
            }
        }
    }
}

