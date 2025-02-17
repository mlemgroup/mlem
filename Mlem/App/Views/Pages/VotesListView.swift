//
//  VotesListView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-18.
//

import MlemMiddleware
import SwiftUI

struct VotesListView: View {
    enum Target: Hashable {
        case post(any Post)
        case comment(any Comment2Providing)
        
        static func == (lhs: Target, rhs: Target) -> Bool {
            switch (lhs, rhs) {
            case let (.post(post1), .post(post2)):
                post1.actorId == post2.actorId
            case let (.comment(comment1), .comment(comment2)):
                comment1.actorId == comment2.actorId
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .post(post): hasher.combine(post.actorId)
            case let .comment(comment): hasher.combine(comment.actorId)
            }
        }
        
        var model: any Interactable1Providing {
            switch self {
            case let .post(post): post
            case let .comment(comment): comment
            }
        }
    }
    
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    let target: Target
    
    @State var votes: [PersonVote] = []
    @State var page: Int = 1
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: Constants.main.halfSpacing) {
                ForEach(votes, id: \.creator.id) { (vote: PersonVote) in
                    NavigationLink(.person(vote.creator)) {
                        HStack {
                            FullyQualifiedLinkView(vote.creator, labelStyle: .medium)
                            Spacer()
                            Image(systemName: vote.vote.systemImage)
                                .imageScale(.large)
                                .symbolVariant(.fill)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(palette.selectedInteractionBarItem, vote.vote.color)
                        }
                    }
                    .padding([.vertical, .trailing], Constants.main.halfSpacing)
                    .padding(.leading, Constants.main.standardSpacing)
                    .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                    .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
                    .contextMenu {
                        vote.creator.menuActions(navigation: navigation, community: target.model.community_)
                    }
                    .padding(.horizontal, Constants.main.standardSpacing)
                }
                EndOfFeedView(loadingState: loadingState, viewType: .turtle)
                    .onAppear {
                        loadNextPage()
                    }
            }
        }
        .environment(\.communityContext, target.model.community_)
        .background(palette.groupedBackground)
        .navigationTitle("Votes")
    }
    
    func loadNextPage() {
        Task { @MainActor in
            guard loadingState == .idle else { return }
            loadingState = .loading
            do {
                let newVotes: [PersonVote]
                switch target {
                case let .post(post):
                    newVotes = try await post.getVotes(page: page, limit: 40)
                case let .comment(comment):
                    newVotes = try await comment.getVotes(page: page, limit: 40)
                }
                votes.append(contentsOf: newVotes)
                if newVotes.count < 40 {
                    loadingState = .done
                } else {
                    loadingState = .idle
                }
                page += 1
            } catch {
                handleError(error)
                loadingState = .idle
            }
        }
    }
}
