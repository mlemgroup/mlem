//
//  VotesListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Dependencies
import SwiftUI

struct VotesListView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @StateObject var votesTracker: VotesTracker
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    let content: any ContentIdentifiable
    
    init(content: any ContentIdentifiable) {
        self.content = content
        self._votesTracker = .init(wrappedValue: .init(content: content))
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
                if votesTracker.votes.isEmpty {
                    LoadingView(whatIsLoading: .votes)
                } else {
                    Divider()
                    ForEach(votesTracker.votes, id: \.id) { item in
                        voteRow(item: item)
                        Divider()
                    }
                    EndOfFeedView(loadingState: votesTracker.loadingState, viewType: .hobbit, whatIsLoading: .votes)
                }
                Spacer().frame(height: 50)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Votes")
        .onAppear {
            if votesTracker.votes.isEmpty {
                votesTracker.loadNextPage()
            }
        }
    }
    
    @ViewBuilder
    func voteRow(item: VoteModel) -> some View {
        NavigationLink(.userProfile(item.user, communityContext: communityContext)) {
            HStack {
                UserLinkView(
                    user: item.user,
                    serverInstanceLocation: .bottom,
                    bannedFromCommunity: item.creatorBannedFromCommunity
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
            ForEach(menuFunctions(for: item)) { item in
                MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
            }
        }
        .onAppear {
            if item.id == votesTracker.votes.last?.id {
                votesTracker.loadNextPage()
            }
        }
    }
    
    func menuFunctions(for item: VoteModel) -> [MenuFunction] {
        guard siteInformation.userId != item.user.userId else { return [] }
        
        var functions = [MenuFunction]()
        
        if !(siteInformation.isAdmin && item.creatorBannedFromCommunity && item.user.banned) {
            functions.append(MenuFunction.toggleableMenuFunction(
                toggle: item.creatorBannedFromCommunity,
                trueText: "Unban User",
                trueImageName: Icons.communityUnban,
                falseText: "Ban User",
                falseImageName: item.user.banned ? Icons.communityBan : Icons.instanceBan,
                isDestructive: .whenFalse
            ) {
                modToolTracker.banUser(
                    item.user,
                    from: communityContext,
                    bannedFromCommunity: item.creatorBannedFromCommunity,
                    shouldBan: !item.creatorBannedFromCommunity,
                    userRemovalWalker: .init(votesTracker: votesTracker)
                )
            })
        }
    
        if siteInformation.isAdmin, item.user.banned || item.creatorBannedFromCommunity {
            functions.append(MenuFunction.toggleableMenuFunction(
                toggle: item.user.banned,
                trueText: "Unban User",
                trueImageName: Icons.instanceUnban,
                falseText: "Ban User",
                falseImageName: Icons.instanceBan,
                isDestructive: .whenFalse
            ) {
                modToolTracker.banUser(
                    item.user,
                    from: communityContext,
                    bannedFromCommunity: item.creatorBannedFromCommunity,
                    shouldBan: !item.user.banned,
                    userRemovalWalker: .init(votesTracker: votesTracker)
                )
            })
        }
        if siteInformation.isAdmin {
            functions.append(.standardMenuFunction(
                text: "Purge User",
                imageName: Icons.purge,
                isDestructive: true
            ) {
                modToolTracker.purgeContent(item.user, userRemovalWalker: .init(votesTracker: votesTracker))
            })
        }
        
        return functions
    }
}
