//
//  PostRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-31.
//

import Foundation
import Dependencies

class PostRepository {
    
    @Dependency(\.apiClient) private var apiClient
    
    func markRead(for postId: Int, read: Bool) async throws -> APIPostView {
        do {
            let response = try await apiClient.markPostAsRead(for: postId, read: read)
            return response.postView
        } catch {
            throw error
        }
    }
}
