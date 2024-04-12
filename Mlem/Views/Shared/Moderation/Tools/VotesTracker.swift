//
//  VotesTracker.swift
//  Mlem
//
//  Created by Sjmarf on 23/03/2024.
//

import Dependencies
import SwiftUI

struct VoteModel: Identifiable {
    var user: UserModel
    let vote: ScoringOperation
    
    // On 0.19.3 and below this is only used for state-faking, and isn't truthful for already existing bans.
    var creatorBannedFromCommunity: Bool
    
    // If I try to access user.userId in a computed property, I get a "Publishing changes from background
    // threads is not allowed" error. Doing this instead, hopefully I can fix this in 2.0 - sjmarf
    let id: Int
    
    init(item: APIVoteView) {
        self.user = .init(from: item.creator)
        self.vote = item.score
        self.creatorBannedFromCommunity = item.creatorBannedFromCommunity ?? false
        self.id = item.creator.id
    }
}

class VotesTracker: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @Published var votes: [VoteModel] = .init()
    @Published var isLoading: Bool = false
    @Published var hasReachedEnd: Bool = false
    
    let content: any ContentIdentifiable
    
    init(content: any ContentIdentifiable) {
        self.content = content
    }
    
    var loadingState: LoadingState {
        if hasReachedEnd { return .done }
        if isLoading { return .loading }
        return .idle
    }
    
    func loadNextPage() {
        if !isLoading, !hasReachedEnd {
            isLoading = true
            Task {
                let page = 1 + votes.count % internetSpeed.pageSize
                do {
                    let newVotes: [APIVoteView]
                    if content is PostModel {
                        let response = try await apiClient.getPostLikes(
                            id: content.uid.contentId,
                            page: page,
                            limit: internetSpeed.pageSize
                        )
                        newVotes = response.postLikes
                    } else if content is HierarchicalComment {
                        let response = try await apiClient.getCommentLikes(
                            id: content.uid.contentId,
                            page: page,
                            limit: internetSpeed.pageSize
                        )
                        newVotes = response.commentLikes
                    } else {
                        newVotes = .init()
                        assertionFailure("Only a PostModel or HierarchicalComment can be used!")
                    }
                    DispatchQueue.main.async { [newVotes] in
                        self.votes.append(contentsOf: newVotes.map(VoteModel.init))
                        if newVotes.count != self.internetSpeed.pageSize {
                            self.hasReachedEnd = true
                        }
                    }
                } catch {
                    errorHandler.handle(error)
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateItem(user: UserModel) {
        if let index = votes.firstIndex(where: { $0.id == user.userId }) {
            votes[index].user = user
        }
    }
}
