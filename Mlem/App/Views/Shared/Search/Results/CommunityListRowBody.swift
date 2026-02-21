//
//  CommunityListRowBody.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-07.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

struct CommunityListRowBody<Content: View>: View {
    enum Complication { case instance, subscriberCount }
    enum Readout { case subscribers }
    
    @Environment(\.isEnabled) var isEnabled
    
    @Setting(\.safety_blurNsfw) var blurNsfw
    
    let community: Community
    let showBlockStatus: Bool
    let complications: [Complication]
    let readout: Readout?
    
    @ViewBuilder let content: () -> Content

    init(
        _ community: Community,
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
        _ community: Community,
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
        var title = community.name
        if community.blocked, showBlockStatus {
            title = title + " ∙ " + String(localized: "Blocked")
        }
        if community.nsfw {
            title = title + " ∙ " + String(localized: "NSFW")
        }
        return title
    }

    var body: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            if community.blocked, showBlockStatus {
                Image(icon: .general.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                CircleCroppedImageView(
                    url: community.avatar?.withIconSize(128),
                    frame: Constants.main.listRowAvatarSize,
                    fallback: .communityAvatar,
                    blurred: community.nsfw && (blurNsfw != .never)
                )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(titleColor)
                caption
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
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
                        Text(verbatim: "@\(community.host)")
                    case .subscriberCount:
                        ExpectedView(community.subscription) { subscription in
                            HStack(spacing: 2) {
                                Image(icon: .lemmy.person)
                                Text(subscription.total.abbreviated)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var titleColor: ThemedColor {
        if community.nsfw {
            .themedWarning
        } else {
            isEnabled ? .themedPrimary : .themedSecondary
        }
    }
    
    var subscriberCountReadout: some View {
        let icon: Icon
        let color: ThemedColor
        switch community.subscriptionTier {
        case .favorited:
            color = .themedFavorite
            icon = .lemmy.favorite
        case .subscribed:
            color = .themedPositive
            icon = .lemmy.subscribed
        case .unsubscribed:
            color = .themedSecondary
            icon = .lemmy.person
        }
        return HStack {
            Text((community.subscription.value?.total ?? 0).abbreviated)
            Image(icon: icon)
                .fontWeight(.semibold)
        }
        .monospacedDigit()
        .foregroundStyle(color)
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        CommunityListRowBody(
//            Community2.mock(.generic),
//            complications: [.instance],
//            readout: .subscribers
//        )
//        .padding(.vertical, Constants.main.standardSpacing)
//    }
// #endif
