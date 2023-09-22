//
//  CommunityModel.swift
//  Mlem
//
//  Created by Sjmarf on 20/09/2023.
//

import Dependencies
import Foundation

protocol ContentModel {
    var uid: ContentModelIdentifier { get }
    var imageUrls: [URL] { get }
}

struct CommunityModel: ContentModel {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    let communityId: Int
    var community: APICommunity
    var subscribed: Bool
    var subscriberCount: Int
    
    var uid: ContentModelIdentifier { .init(contentType: .community, contentId: communityId) }
    var imageUrls: [URL] {
        if let url = community.iconUrl {
            return [url.withIcon64Parameters]
        }
        return []
    }
    
    /// Creates a CommunityModel from an APICommunityView
    /// - Parameter apiCommunityView: APICommunityView to create a CommunityModel representation of
    init(from apiCommunityView: APICommunityView) {
        self.communityId = apiCommunityView.community.id
        self.community = apiCommunityView.community
        self.subscriberCount = apiCommunityView.counts.subscribers
        self.subscribed = apiCommunityView.subscribed != .notSubscribed ? true : false
    }
    
    mutating func toggleSubscribe(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async {
        subscribed.toggle()
        if subscribed {
            subscriberCount += 1
        } else {
            subscriberCount -= 1
        }
        RunLoop.main.perform { [self] in
            callback(self)
        }
        do {
            try await apiClient.followCommunity(id: communityId, shouldFollow: subscribed)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
}

extension CommunityModel: Identifiable {
    var id: Int { hashValue }
}

extension CommunityModel: Hashable {
    static func == (lhs: CommunityModel, rhs: CommunityModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(community.id)
        hasher.combine(subscribed)
    }
}
