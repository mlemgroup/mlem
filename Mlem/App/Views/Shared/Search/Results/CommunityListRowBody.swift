//
//  CommunityListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import MlemMiddleware
import SwiftUI

struct CommunityListRowBody<Content: View>: View {
    enum Complication { case instance, subscriberCount }
    
    let community: any Community
    let showBlockStatus: Bool
    let complications: [Complication]
    
    @ViewBuilder let content: () -> Content

    init(
        _ community: any Community,
        complications: [Complication] = [.instance],
        showBlockStatus: Bool = true,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.community = community
        self.showBlockStatus = showBlockStatus
        self.content = content
        self.complications = complications
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
        HStack(spacing: AppConstants.standardSpacing) {
            if community.blocked, showBlockStatus {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                AvatarView(url: community.avatar?.withIconSize(128), type: .community)
                    .frame(height: 46)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(community.nsfw ? .red : .primary)
                caption
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            content()
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    var caption: some View {
        HStack(spacing: 2) {
            ForEach(Array(complications.enumerated()), id: \.element) { index, complication in
                if index != 0 {
                    Text("∙")
                }
                Group {
                    switch complication {
                    case .instance:
                        if let host = community.host {
                            Text("@\(host)")
                        }
                    case .subscriberCount:
                        if let subscriberCount = community.subscriberCount_ {
                            Image(systemName: Icons.person)
                            Text(subscriberCount.abbreviated)
                        }
                    }
                }
            }
        }
    }
}
