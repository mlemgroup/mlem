//
//  UserResultView.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import SwiftUI

struct UserResultView: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    @EnvironmentObject var contentTracker: ContentTracker<AnyContentModel>
    let user: UserModel
    let showTypeLabel: Bool
    
    var caption: String {
        if let host = user.profileUrl.host {
            if showTypeLabel {
                return "User ∙ @\(host)"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return "@\(host) ∙ \(dateFormatter.string(from: user.creationDate))"
            }
        }
        return "Unknown instance"
    }
    
    var body: some View {
        NavigationLink(value: NavigationRoute.userProfile(user)) {
            HStack(spacing: 10) {
                AvatarView(user: user, avatarSize: 48)
                let flair = user.getFlair()
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        if let flair = flair {
                            Image(systemName: flair.icon)
                                .imageScale(.small)
                        }
                        Text(user.name)
                    }
                    .foregroundStyle(flair?.color ?? .primary)
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if showTypeLabel {
                    HStack(spacing: 5) {
                        if let commentCount = user.commentCount {
                            Text(abbreviateNumber(commentCount))
                                .monospacedDigit()
                            Image(systemName: Icons.replies)
                        }
                    }
                    .foregroundStyle(.secondary)
                } else {
                    if let commentCount = user.commentCount, let postCount = user.postCount {
                        HStack(spacing: 5) {
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(abbreviateNumber(postCount))
                                    .font(.subheadline)
                                    .monospacedDigit()
                                Text(abbreviateNumber(commentCount))
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                            .foregroundStyle(.secondary)
                            VStack(spacing: 10) {
                                Image(systemName: Icons.posts)
                                    .imageScale(.small)
                                Image(systemName: Icons.replies)
                                    .imageScale(.small)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .draggable(user.profileUrl) {
            HStack {
                AvatarView(user: user, avatarSize: 24)
                Text(user.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
