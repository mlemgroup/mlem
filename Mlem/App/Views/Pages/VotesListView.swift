//
//  VotesListView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-18.
//

import MlemMiddleware
import SwiftUI
import Theming

struct VotesListView: View {
    enum Target: Hashable {
        case post(Post)
        case comment(Comment)
        
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
        
        var model: any InteractableProviding {
            switch self {
            case let .post(post): post
            case let .comment(comment): comment
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    let target: Target
    
    @State var votes: [PersonVote] = []
    @State var location: PageLocation = .start
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: Constants.main.halfSpacing) {
                ForEach(votes, id: \.creator.id, content: rowView)
                EndOfFeedView(loadingState: loadingState, viewType: .turtle)
                    .onAppear {
                        loadNextPage()
                    }
            }
        }
        .environment(\.communityContext, target.model.community.value)
        .themedGroupedBackground()
        .navigationTitle("Votes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func rowView(_ vote: PersonVote) -> some View {
        NavigationLink(.person(vote.creator)) {
            rowViewLabel(vote)
        }
        .padding([.vertical, .trailing], Constants.main.halfSpacing)
        .padding(.leading, Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu(person: vote.creator)
        .padding(.horizontal, Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func rowViewLabel(_ vote: PersonVote) -> some View {
        HStack {
            FullyQualifiedLinkView(vote.creator, labelStyle: .medium)
            Spacer()
            Image(systemName: vote.vote.systemImage)
                .imageScale(.large)
                .symbolVariant(.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.themedContrastingLabel, vote.vote.color)
        }
    }
    
    func loadNextPage() {
        Task { @MainActor in
            guard loadingState == .idle, let cursor = location.cursor else { return }
            loadingState = .loading
            do {
                let response: PagedResponse<PersonVote>
                switch target {
                case let .post(post):
                    response = try await post.getVotes(pageInfo: .init(cursor: cursor, limit: 40))
                case let .comment(comment):
                    // TODO: handle this better--call refresh first?
                    guard let communityId = comment.community.value_?.id else {
                        assertionFailure("loadNextPage called without resolved community")
                        response = .init(items: [], nextLocation: .end)
                        break
                    }
                    response = try await comment.getVotes(
                        pageInfo: .init(cursor: cursor, limit: 40),
                        communityId: communityId
                    )
                }
                votes.append(contentsOf: response.items)
                loadingState = response.nextLocation == .end ? .done : .idle
                self.location = response.nextLocation
            } catch {
                handleError(error)
                loadingState = .idle
            }
        }
    }
}
