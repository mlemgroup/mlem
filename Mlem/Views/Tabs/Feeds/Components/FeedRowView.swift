//
//  FeedRowView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Dependencies
import Foundation
import SwiftUI

struct FeedRowView: View {
    let feedType: PostFeedType
    
    var body: some View {
        HStack {
            FeedIconView(feedType: feedType, size: 30)
            Text(feedType.label)
        }
    }
}

struct FeedIconView: View {
    let feedType: any FeedType
    let size: CGFloat
    
    var body: some View {
        Circle().fill(feedType.color ?? .blue)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: feedType.iconNameFill)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: size * feedType.iconScaleFactor, height: size * feedType.iconScaleFactor)
            }
    }
}

struct CommunityFeedRowView: View {
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void
    let navigationContext: NavigationContext
    
    var body: some View {
        HStack {
            communityNameLabel
            
            Spacer()
            
            Button("Favorite Community") {
                hapticManager.play(haptic: .success, priority: .high)
                toggleFavorite()
            }
            .buttonStyle(FavoriteStarButtonStyle(isFavorited: isFavorited()))
            .accessibilityHidden(true)
        }.swipeActions {
            if subscribed {
                Button {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: false)
                    }
                } label: {
                    Label("Unsubscribe", systemImage: Icons.unsubscribe)
                }
                .tint(.red) // Destructive role seems to remove from list so just make it red
            } else {
                Button {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: true)
                    }
                } label: {
                    Label("Subscribe", systemImage: Icons.subscribe)
                }.tint(.blue)
            }
        }
        .accessibilityAction(named: "Toggle favorite") {
            toggleFavorite()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(communityLabel)
    }
    
    private var communityNameText: Text {
        Text(community.name)
    }
    
    @ViewBuilder
    private var communityNameLabel: some View {
        if let website = community.actorId.host(percentEncoded: false) {
            communityNameText +
                Text("@\(website)")
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.5))
        } else {
            communityNameText
        }
    }
    
    private var communityLabel: String {
        var label = community.name
        
        if let website = community.actorId.host(percentEncoded: false) {
            label += "@\(website)"
        }
        
        if isFavorited() {
            label += ", is a favorite"
        }
        
        return label
    }
    
    private func toggleFavorite() {
        if isFavorited() {
            favoriteCommunitiesTracker.unfavorite(community.id)
            UIAccessibility.post(notification: .announcement, argument: "Unfavorited \(community.name)")
            Task {
                await notifier.add(.success("Unfavorited \(community.name)"))
            }
        } else {
            favoriteCommunitiesTracker.favorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Favorited \(community.name)")
            Task {
                await notifier.add(.success("Favorited \(community.name)"))
            }
        }
    }
    
    private func isFavorited() -> Bool {
        favoriteCommunitiesTracker.isFavorited(community)
    }
    
    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        communitySubscriptionChanged(community, shouldSubscribe)
    }
}
