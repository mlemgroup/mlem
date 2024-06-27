//
//  CommunityListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import MlemMiddleware
import SwiftUI

struct CommunityListRowBody: View {
    let community: any Community
    let showBlockStatus: Bool

    init(
        _ community: any Community,
        showBlockStatus: Bool = true
    ) {
        self.community = community
        self.showBlockStatus = showBlockStatus
    }
    
    var title: String {
        var suffix = ""
        if community.blocked, showBlockStatus {
            suffix.append(" ∙ Blocked")
        }
        if community.nsfw {
            suffix.append("∙ NSFW")
        }
        return community.name + suffix
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if community.blocked, showBlockStatus {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                AvatarView(community)
                    .frame(height: 46)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(community.nsfw ? .red : .primary)
                Text("@\(community.host ?? "unknown")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}
