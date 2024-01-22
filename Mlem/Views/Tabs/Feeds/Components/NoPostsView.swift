//
//  NoPostsView.swift
//  Mlem
//
//  Created by Sjmarf on 10/10/2023.
//

import SwiftUI

struct NoPostsView: View {
    @EnvironmentObject var postTracker: StandardPostTracker
    
    let loadingState: LoadingState
    @Binding var postSortType: PostSortType
    @Binding var showReadPosts: Bool
    
    var body: some View {
        VStack {
            if loadingState != .loading {
                VStack(alignment: .center, spacing: AppConstants.postAndCommentSpacing) {
                    let unreadItems = postTracker.getFilteredCount(for: .read)
                    
                    Image(systemName: Icons.noPosts)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35)
                        .padding(.bottom, 12)
                        .frame(width: unreadItems == 0 ? 35 : 50)
                        .padding(.bottom, unreadItems == 0 ? 8 : 12)
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
                    postSortType = .hot
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
        .padding(.top)
        .padding(.horizontal, 20)
    }
}
