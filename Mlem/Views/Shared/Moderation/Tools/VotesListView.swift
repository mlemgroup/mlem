//
//  VotesListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Dependencies
import SwiftUI

struct VotesListView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
        
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    let content: any ContentIdentifiable
    @State var votes: [APIVoteView] = .init()
    @State var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if votes.isEmpty {
                    LoadingView(whatIsLoading: .votes)
                } else {
                    ForEach(votes, id: \.creator.id) { item in
                        HStack {
                            Text(item.creator.name)
                        }
                        .onAppear {
                            if item.creator == votes.last?.creator {
                                loadNextPage()
                            }
                        }
                    }
                }
                Spacer().frame(height: 50)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Votes")
        .onAppear {
            if votes.isEmpty {
                loadNextPage()
            }
        }
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
                    votes.append(contentsOf: response.postLikes)
                } catch {
                    errorHandler.handle(error)
                }
                isLoading = false
            }
        }
    }
}
