//
//  NoPostsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/10/2023.
//

import SwiftUI

struct NoPostsView: View {
    @EnvironmentObject var postTracker: PostTracker
    
    @Binding var isLoading: Bool
    @Binding var postSortType: PostSortType
    @Binding var showReadPosts: Bool
    
    var body: some View {
        VStack {
            if !isLoading {
                VStack(alignment: .center, spacing: AppConstants.postAndCommentSpacing) {
                    
                    let unreadItems = postTracker.hiddenItems[.read, default: 0]
                    
                    Image(systemName: Icons.noPosts)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: unreadItems == 0 ? 35 : 50)
                        .padding(.bottom, unreadItems == 0 ? 8: 12)
                    Text(title)
                    
                    if unreadItems != 0 {
                        Text(
                            (unreadItems == 1 ? "1 available post was" : "\(unreadItems) available posts were")
                            + " hidden because you have 'hide read' enabled."
                        )
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        
                    }
                    buttons
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    var title: String {
        if PostSortType.topTypes.contains(postSortType) && postSortType != .topAll {
            return "No posts found from the last \(postSortType.label.lowercased())."
        }
        return "No posts found."
    }
    
    @ViewBuilder
    var buttons: some View {
        VStack {
            if postSortType != .hot {
                Button {
                    isLoading = true
                    postSortType = .hot
                } label: {
                    Label("Switch to Hot", systemImage: Icons.hotSort)
                }
            }
            if postTracker.hiddenItems[.read, default: 0] > 0 {
                Button {
                    if !showReadPosts {
                        isLoading = true
                        showReadPosts = true
                    }
                } label: {
                    Text("Show read posts")
                }
            }
        }
        .foregroundStyle(.secondary)
        .buttonStyle(.bordered)
        .padding(.top)
        .padding(.horizontal, 20)
    }
}
