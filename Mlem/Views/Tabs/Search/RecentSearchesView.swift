//
//  RecentSearchesView.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import SwiftUI

struct RecentSearchesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker
    @StateObject var contentTracker: ContentTracker<AnyContentModel> = .init()
    
    func deleteSwipeAction(_ item: AnyContentModel) -> SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: Icons.close, fillName: Icons.close),
            color: .red,
            action: {
                recentSearchesTracker.removeRecentSearch(item, accountId: appState.currentActiveAccount?.stableIdString)
            }
        )
    }
    
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
                recentSearchesTracker.clearRecentSearches(accountId: appState.currentActiveAccount?.stableIdString)
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
                    CommunityResultView(
                        community,
                        complications: .withTypeLabel,
                        swipeActions: .init(trailingActions: [deleteSwipeAction(contentModel)]),
                        trackerCallback: {
                            contentTracker.update(with: AnyContentModel($0))
                        }
                    )
                } else if let user = contentModel.wrappedValue as? UserModel {
                    UserResultView(
                        user,
                        complications: [.type, .instance, .comments],
                        swipeActions: .init(trailingActions: [deleteSwipeAction(contentModel)]),
                        trackerCallback: {
                            contentTracker.update(with: AnyContentModel($0))
                        }
                    )
                } else if let instance = contentModel.wrappedValue as? InstanceModel {
                    InstanceResultView(
                        instance,
                        complications: .withTypeLabel,
                        swipeActions: .init(trailingActions: [deleteSwipeAction(contentModel)])
                    )
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                recentSearchesTracker.addRecentSearch(contentModel, accountId: appState.currentActiveAccount?.stableIdString)
            })
            Divider()
        }
    }
    
    @ViewBuilder
    private var noRecentSearchesView: some View {
        VStack(spacing: 20) {
            Image(systemName: Icons.search)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .fontWeight(.thin)
            Text("Search for communities, users and instances.")
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.secondary)
        .padding(100)
        .transition(.opacity)
    }
}

#Preview {
    RecentSearchesViewPreview()
}

struct RecentSearchesViewPreview: View {
    @StateObject var appState: AppState = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()

    var body: some View {
        RecentSearchesView()
            .environmentObject(appState)
            .environmentObject(recentSearchesTracker)
    }
}
