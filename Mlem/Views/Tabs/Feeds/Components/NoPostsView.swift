//
//  NoPostsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/10/2023.
//

import SwiftUI

struct NoPostsView: View {
    @Environment(StandardPostTracker.self) var postTracker
    
    let loadingState: LoadingState
    let postSortType: PostSortType
    @Binding var showReadPosts: Bool
    // this isn't the most elegant but passing a nested binding doesn't seem to propagate changes correctly [Eric 2024.01.25]
    let switchToHot: () -> Void
    
    var body: some View {
        VStack {
            if loadingState != .loading {
                VStack(alignment: .center, spacing: 0) {
                    let unreadItems = postTracker.getFilteredCount(for: .read)
                    
                    Image(systemName: Icons.noPosts)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35)
                        .padding(.vertical, 35)
                        .padding(.top, 10) // offsets the illusion of whitespace created by lowercase letters below
                    
                    VStack(spacing: AppConstants.postAndCommentSpacing) {
                        Text(title)
                        
                        if unreadItems != 0 {
                            Text(
                                "\(unreadItems) read post\(unreadItems == 1 ? " has" : "s have") been hidden."
                            )
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                        }
                        
                        buttons
                            .padding(.top)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    var title: String {
        if PostSortType.topTypes.contains(postSortType), postSortType != .topAll {
            return "No posts found from the last \(postSortType.label.lowercased())."
        }
        return "No posts found."
    }
    
    @ViewBuilder
    var buttons: some View {
        VStack {
            if postSortType != .hot {
                Button {
                    switchToHot()
                } label: {
                    Label("Switch to Hot", systemImage: Icons.hotSort)
                }
            }
            if postTracker.getFilteredCount(for: .read) > 0 {
                Button {
                    if !showReadPosts {
                        showReadPosts = true
                    }
                } label: {
                    Text("Show read posts")
                }
            }
        }
        .foregroundStyle(.secondary)
        .buttonStyle(.bordered)
    }
}
