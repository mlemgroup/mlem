//
//  BlockListView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 19/04/2024.
//

import Foundation

extension BlockListView {
    func loadItems() async {
        isLoading = true
        errorDetails = nil
        do {
            let info = try await apiClient.loadSiteInformation()
            if let myUser = info.myUser {
                DispatchQueue.main.async {
                    self.communities = myUser.communityBlocks.map { .init(from: $0.community, blocked: true) }
                    self.users = myUser.personBlocks.map { .init(from: $0.target, blocked: true) }
                    self.instances = myUser.instanceBlocks?.map(\.instance) ?? .init()
                    self.isLoading = false
                }
            }
        } catch {
            isLoading = false
            errorDetails = .init(error: error)
        }
    }
    
    func unblockInstance(id: Int) {
        Task {
            do {
                try await apiClient.blockSite(id: id, shouldBlock: false)
                await notifier.add(.success("Unblocked instance"))
                if let index = instances.firstIndex(
                    where: { $0.id == id }
                ) {
                    instances.remove(at: index)
                }
            } catch {
                await notifier.add(.failure("Failed to unblock instance"))
            }
        }
    }
    
    func removeUser(_ user: UserModel) {
        if !user.blocked, let index = users.firstIndex(
            where: { $0.userId == user.userId }
        ) {
            users.remove(at: index)
        }
    }
    
    func removeCommunity(_ community: CommunityModel) {
        if !(community.blocked ?? true), let index = communities.firstIndex(
            where: { $0.communityId == community.communityId }
        ) {
            communities.remove(at: index)
        }
    }
}
