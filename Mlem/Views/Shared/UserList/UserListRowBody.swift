//
//  UserRow.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation
import SwiftUI

struct UserListRowBody: View {
    let user: UserModel
    let communityContext: CommunityModel?
    let complications: [UserComplication]
    let navigationEnabled: Bool
    
    var title: String {
        if user.blocked {
            return "\(user.displayName!) ∙ Blocked"
        } else {
            return user.displayName
        }
    }
    
    var caption: String {
        var parts: [String] = []
        if complications.contains(.type) {
            parts.append("User")
        }
        if complications.contains(.instance), let host = user.profileUrl.host {
            parts.append("@\(host)")
        }
        if complications.contains(.date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            parts.append(dateFormatter.string(from: user.creationDate))
        }
        return parts.joined(separator: " ∙ ")
    }
    
    var body: some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
    }
    
    var content: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            if user.blocked {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                AvatarView(user: user, avatarSize: 48, iconResolution: .fixed(128))
            }
            let flairs = user.getFlairs(communityContext: communityContext)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(flairs, id: \.self) { flair in
                        Image(systemName: flair.icon)
                            .imageScale(.small)
                            .foregroundStyle(flair.color)
                    }
                    Text(title)
                        .lineLimit(1)
                }
                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            trailingInfo
            
            if navigationEnabled {
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    @ViewBuilder
    var trailingInfo: some View {
        Group {
            if complications.contains(.posts), let postCount = user.postCount {
                if complications.contains(.comments), let commentCount = user.commentCount {
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
                } else {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(postCount))
                            .monospacedDigit()
                        Image(systemName: Icons.posts)
                    }
                    .foregroundStyle(.secondary)
                }
            } else if complications.contains(.comments), let commentCount = user.commentCount {
                HStack(spacing: 5) {
                    Text(abbreviateNumber(commentCount))
                        .monospacedDigit()
                    Image(systemName: Icons.replies)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
