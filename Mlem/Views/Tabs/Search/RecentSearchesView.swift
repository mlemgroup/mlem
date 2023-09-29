//
//  RecentSearchesView.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import SwiftUI

struct RecentSearchesView: View {
    
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker
    @StateObject var contentTracker: ContentTracker<AnyContentModel> = .init()
    
    var body: some View {
        Group {
            if !recentSearchesTracker.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    .padding(.top, 15)
                    .padding(.bottom, 6)
                    Divider()
                    itemsView
                }
                .transition(.opacity)
            } else {
                noRecentSearchesView
            }
        }
        .animation(.default, value: recentSearchesTracker.recentSearches.isEmpty)
        .frame(maxWidth: .infinity)
        .onAppear {
            contentTracker.replaceAll(with: recentSearchesTracker.recentSearches)
        }
        .onChange(of: recentSearchesTracker.recentSearches) { _ in
            contentTracker.replaceAll(with: recentSearchesTracker.recentSearches)
        }
        .environmentObject(contentTracker)
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            Text("Recently Searched")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            
            Button {
                Task {
                    recentSearchesTracker.clearRecentSearches()
                }
            } label: {
                Text("Clear")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var itemsView: some View {
        ForEach(contentTracker.items, id: \.uid) { contentModel in
            Group {
                if let community = contentModel.wrappedValue as? CommunityModel {
                    CommunityResultView(community: community, showTypeLabel: true)
                } else if let user = contentModel.wrappedValue as? UserModel {
                    UserResultView(user: user, showTypeLabel: true)
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                recentSearchesTracker.addRecentSearch(contentModel)
                // Keyboard.dismiss()
            })
            Divider()
        }
    }
    
    @ViewBuilder
    private var noRecentSearchesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .fontWeight(.thin)
            Text("Search for communities and users.")
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.secondary)
        .padding(100)
        .transition(.opacity)
    }
}
