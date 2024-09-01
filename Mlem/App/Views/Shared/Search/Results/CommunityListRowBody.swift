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
    enum Readout { case subscribers }

    @Setting(\.blurNsfw) var blurNsfw
    
    @Environment(Palette.self) var palette
    
    let community: any Community
    let showBlockStatus: Bool
    let complications: [Complication]
    let readout: Readout?
    
    @ViewBuilder let content: () -> Content

    init(
        _ community: any Community,
        complications: [Complication] = [.instance],
        showBlockStatus: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.community = community
        self.showBlockStatus = showBlockStatus
        self.readout = nil
        self.content = content
        self.complications = complications
    }
    
    init(
        _ community: any Community,
        complications: [Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Readout? = nil
    ) where Content == EmptyView {
        self.community = community
        self.showBlockStatus = showBlockStatus
        self.readout = readout
        self.content = { EmptyView() }
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
        HStack(spacing: Constants.main.standardSpacing) {
            if community.blocked, showBlockStatus {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                CircleCroppedImageView(
                    url: community.avatar?.withIconSize(128),
                    size: Constants.main.listRowAvatarSize,
                    fallback: .community,
                    blurred: community.nsfw && (blurNsfw != .never)
                )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(community.nsfw ? palette.warning : palette.primary)
                caption
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
                    .lineLimit(1)
            }
            Spacer()
            switch readout {
            case .subscribers:
                subscriberCountReadout
            case nil:
                content()
            }
        }
        .padding(.horizontal)
        .contentShape(.rect)
    }
    
    @ViewBuilder
    var caption: some View {
        HStack(spacing: 2) {
            ForEach(Array(complications.enumerated()), id: \.element) { index, complication in
                if index != 0 {
                    Text(verbatim: "∙")
                }
                Group {
                    switch complication {
                    case .instance:
                        if let host = community.host {
                            Text(verbatim: "@\(host)")
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
    
    var subscriberCountReadout: some View {
        let image: String
        let color: Color
        switch community.subscriptionTier_ {
        case .favorited:
            color = palette.favorite
            image = Icons.favoriteFill
        case .subscribed:
            color = palette.positive
            image = Icons.successCircleFill
        case .unsubscribed, nil:
            color = palette.secondary
            image = Icons.personFill
        }
        return HStack {
            Text((community.subscriberCount_ ?? 0).abbreviated)
            Image(systemName: image)
                .fontWeight(.semibold)
        }
        .monospacedDigit()
        .foregroundStyle(color)
        .symbolRenderingMode(.hierarchical)
    }
}
