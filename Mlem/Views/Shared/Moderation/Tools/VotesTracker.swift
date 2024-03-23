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
    
    // This is only used for state-faking, and isn't truthful for already existing bans.
    // I opened an issue for proper support here https://github.com/LemmyNet/lemmy/issues/4561
    var creatorBannedFromCommunity: Bool = false
    
    // If I try to access user.userId in a computed property, I get a "Publishing changes from background
    // threads is not allowed" error. Doing this instead, hopefully I can fix this in 2.0 - sjmarf
    let id: Int
    
    init(item: APIVoteView) {
        self.user = .init(from: item.creator)
        self.vote = item.score
        self.id = item.creator.id
    }
}

class VotesTracker: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @Published var votes: [VoteModel] = .init()
    @Published var isLoading: Bool = false
    
    let content: any ContentIdentifiable
    
    init(content: any ContentIdentifiable) {
        self.content = content
    }
    
    func loadNextPage() {
        if !isLoading {
            isLoading = true
            Task {
                let page = 1 + votes.count % internetSpeed.pageSize
                do {
                    let response = try await apiClient.getPostLikes(
                        id: content.uid.contentId,
                        page: page,
                        limit: internetSpeed.pageSize
                    )
                    DispatchQueue.main.async {
                        self.votes.append(contentsOf: response.postLikes.map(VoteModel.init))
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
        if let index = votes.firstIndex(where: {$0.id == user.userId}) {
            votes[index].user = user
        }
    }
}
