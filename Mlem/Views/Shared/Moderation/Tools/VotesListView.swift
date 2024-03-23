//
//  VotesListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Dependencies
import SwiftUI

struct VotesListView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @StateObject var votesListModel: VotesListModel
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    let content: any ContentIdentifiable
    
    init(content: any ContentIdentifiable) {
        self.content = content
        self._votesListModel = .init(wrappedValue: .init(content: content))
    }
    
    var communityContext: CommunityModel? {
        if let post = content as? PostModel {
            return post.community
        } else if let comment = content as? HierarchicalComment {
            return CommunityModel(from: comment.commentView.community)
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if votesListModel.votes.isEmpty {
                    LoadingView(whatIsLoading: .votes)
                } else {
                    Divider()
                    ForEach(votesListModel.votes, id: \.id) { item in
                        NavigationLink(.userProfile(item.user, communityContext: communityContext)) {
                            HStack {
                                UserLinkView(
                                    user: item.user,
                                    serverInstanceLocation: .bottom,
                                    bannedFromCommunity: false
                                )
                                Spacer()
                                Image(systemName: item.vote.iconNameFill)
                                    .foregroundStyle(item.vote.color ?? .primary)
                                    .imageScale(.large)
                            }
                            .padding(.horizontal, AppConstants.standardSpacing)
                            .padding(.vertical, 8)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            ForEach(
                                item.user.menuFunctions(votesListModel.updateItem, modToolTracker: modToolTracker)
                            ) { item in
                                MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                            }
                        }
                        .onAppear {
                            if item.id == votesListModel.votes.last?.id {
                                votesListModel.loadNextPage()
                            }
                        }
                        Divider()
                    }
                }
                Spacer().frame(height: 50)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Votes")
        .onAppear {
            if votesListModel.votes.isEmpty {
                votesListModel.loadNextPage()
            }
        }
    }
}
