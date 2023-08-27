//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Foundation
import SwiftUI

struct SearchView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @StateObject var searchModel = SearchModel()
    
    // private state
    @State private var navigationPath = NavigationPath()
    @State private var input: String = ""
    
    // constants
    private let searchPageSize = 50

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .handleLemmyViews()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .navigationTitle("Search")
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.navigationPath, $navigationPath)
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .searchable(text: $input, prompt: "Search for communities")
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .task(id: input) {
            do {
                try await searchModel.fetchResults(input)
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    var content: some View {
        ScrollView {
            if input.isEmpty {
                EmptyView()
            } else {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Spacer()
                        .frame(height: 8)
                    tokenResults
                    communityResults
                    userResults
                }
            }
        }
        .coordinateSpace(name: "searchArea")
    }
    
    var tokenResults: some View {
        VStack {
            if searchModel.showSubscribedTokenSuggestion {
                SearchTokenSuggestionView(title: "Subscribed", highlight: searchModel.input) {
                    Image(systemName: "newspaper.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                        .padding(4)
                        .background(Circle().fill(.red))
                }
            }
            
            ForEach(searchModel.communityTokenSuggestions, id: \.self) { community in
                SearchTokenSuggestionView(title: community.community.name, highlight: searchModel.input) {
                    CommunityAvatarView(community: community.community, avatarSize: 20)
                }
            }
        }
    }
    
    var communityResults: some View {
        Section {
            ForEach(searchModel.communities, id: \.self) { community in
                CommunityResultView(community: community, highlight: searchModel.input)
            }
            .padding(.horizontal, 15)
        } header: {
            SearchSectionHeaderView(title: "Communities")
        }
    }
    
    var userResults: some View {
        Section {
            ForEach(searchModel.users, id: \.self) { user in
                UserResultView(user: user, highlight: searchModel.input)
            }
            .padding(.horizontal, 15)
        } header: {
            SearchSectionHeaderView(title: "Users")
        }
    }
}
