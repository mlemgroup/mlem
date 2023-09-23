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
        if let host = user.user.actorId.host {
            if showTypeLabel {
                return "User ∙ @\(host)"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return "@\(host) ∙ \(dateFormatter.string(from: user.user.published))"
            }
        }
        return "Unknown instance"
    }
    
    var body: some View {
        NavigationLink(value: NavigationRoute.apiPerson(user.user)) {
            HStack(spacing: 10) {
                AvatarView(user: user.user, avatarSize: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.user.name)
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if showTypeLabel {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(user.commentCount))
                            .monospacedDigit()
                        Image(systemName: "bubble.left")
                    }
                    .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 5) {
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(abbreviateNumber(user.postCount))
                                .font(.subheadline)
                                .monospacedDigit()
                            Text(abbreviateNumber(user.commentCount))
                                .font(.subheadline)
                                .monospacedDigit()
                        }
                        .foregroundStyle(.secondary)
                        VStack(spacing: 10) {
                            Image(systemName: "doc.plaintext")
                                .imageScale(.small)
                            Image(systemName: "bubble.left")
                                .imageScale(.small)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .draggable(user.user.actorId) {
            HStack {
                AvatarView(user: user.user, avatarSize: 24)
                Text(user.user.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
