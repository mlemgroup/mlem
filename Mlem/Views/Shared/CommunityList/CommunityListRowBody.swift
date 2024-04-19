//
//  CommunityListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import Foundation
import SwiftUI

struct CommunityListRowBody: View {
    let community: CommunityModel
    let complications: [CommunityComplication]
    var showBlockStatus: Bool = true
    let navigationEnabled: Bool
    
    var title: String {
        var suffix = ""
        if (community.blocked ?? false) && showBlockStatus {
            suffix.append(" ∙ Blocked")
        }
        if community.nsfw {
            suffix.append("∙ NSFW")
        }
        return community.name + suffix
    }
    
    var caption: String {
        var parts: [String] = []
        if complications.contains(.type) {
            parts.append("Community")
        }
        if complications.contains(.instance), let host = community.communityUrl.host {
            parts.append("@\(host)")
        }
        return parts.joined(separator: " ∙ ")
    }
    
    var subscriberCountColor: Color {
        if community.favorited {
            return .blue
        }
        if community.subscribed ?? false {
            return .green
        }
        return .secondary
    }
    
    var subscriberCountIcon: String {
        if community.favorited {
            return Icons.favoriteFill
        }
        if community.subscribed ?? false {
            return Icons.subscribed
        }
        return Icons.personFill
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if (community.blocked ?? false) && showBlockStatus {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                AvatarView(community: community, avatarSize: 48, iconResolution: .fixed(128))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(community.nsfw ? .red : .primary)
                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if complications.contains(.subscribers), let subscriberCount = community.subscriberCount {
                HStack(spacing: 5) {
                    Text(subscriberCount.abbreviated)
                        .monospacedDigit()
                    Image(systemName: subscriberCountIcon)
                }
                .foregroundStyle(subscriberCountColor)
            }
            
            if navigationEnabled {
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}
