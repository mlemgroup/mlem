//
//  BanUserView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 09/03/2024.
//

import SwiftUI

extension BanUserView {
    func confirm() {
        if let community {
            communityBan(from: community)
        } else {
            instanceBan()
        }
    }
    
    func instanceBan() {
        isWaiting = true
        Task {
            let reason = reason.isEmpty ? nil : reason
            var user = user
            await user.toggleBan(
                expires: expires,
                reason: reason,
                removeData: contentRemovalType == .remove
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(user.banned)
        }
    }
    
    func communityBan(from community: CommunityModel) {
        isWaiting = true
        Task {
            let updatedBannedStatus = await community.banUser(
                userId: user.userId,
                ban: shouldBan,
                removeData: contentRemovalType == .remove,
                reason: reason.isEmpty ? nil : reason,
                expires: expires
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(updatedBannedStatus)
        }
    }
    
    func handleResult(_ result: Bool) async {
        if result == shouldBan {
            await notifier.add(.success("\(verb.capitalized)"))
            
            await MainActor.run {
                if let postTracker {
                    for post in postTracker.items where post.creator.userId == user.userId {
                        post.creatorBannedFromCommunity = shouldBan
                    }
                }
            }
            
            DispatchQueue.main.async {
                dismiss()
            }
        } else {
            await notifier.add(.failure("Failed to \(verb) user"))
        }
    }
}
