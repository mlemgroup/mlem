//
//  SearchResultListView.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import SwiftUI

struct SearchResultListView: View {
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker
    @EnvironmentObject var contentTracker: ContentTracker<AnyContentModel>
    
    let showTypeLabel: Bool
    
    @State var shouldLoad = false
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(contentTracker.items, id: \.uid) { contentModel in
                Group {
                    if let community = contentModel.wrappedValue as? CommunityModel {
                        CommunityResultView(community: community, showTypeLabel: showTypeLabel)
                    } else if let user = contentModel.wrappedValue as? UserModel {
                        UserResultView(user: user, showTypeLabel: showTypeLabel)
                    }
                }
                .simultaneousGesture(TapGesture().onEnded {
                    recentSearchesTracker.addRecentSearch(contentModel)
                })
                Divider()
                    .onAppear {
                        if contentTracker.shouldLoadContentAfter(after: contentModel) {
                            shouldLoad = true
                        }
                    }
            }
            footer
        }
        .onChange(of: shouldLoad) { value in
            if value {
                print("Loading page \(contentTracker.page + 1)...")
                Task(priority: .medium) { try await contentTracker.loadNextPage() }
            }
            shouldLoad = false
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        VStack {
            if (contentTracker.isLoading && contentTracker.page != 1) || shouldLoad {
                ProgressView()
            } else if contentTracker.items.isEmpty {
                Text("No results found.")
                    .foregroundStyle(.secondary)
            } else if contentTracker.hasReachedEnd && contentTracker.items.count > 10 {
                HStack {
                    Image(systemName: "figure.climbing")
                    Text("I think I've found the bottom!")
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(height: 100)
    }
}
