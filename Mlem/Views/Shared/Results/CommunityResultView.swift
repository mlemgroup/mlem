//
//  CommunityResultView.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import Dependencies
import SwiftUI

enum CommunityComplication: CaseIterable {
    case type, instance, subscribers
}

extension [CommunityComplication] {
    static let withTypeLabel: [CommunityComplication] = [.type, .instance, .subscribers]
    static let withoutTypeLabel: [CommunityComplication] = [.instance, .subscribers]
    static let instanceOnly: [CommunityComplication] = [.instance]
}

struct CommunityResultView: View {
    @Dependency(\.hapticManager) var hapticManager
    
    let community: any Community
    let swipeActions: SwipeConfiguration?
    let complications: [CommunityComplication]

    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
        
    init(
        _ community: any Community,
        complications: [CommunityComplication] = .withoutTypeLabel,
        swipeActions: SwipeConfiguration? = nil
    ) {
        self.community = community
        self.complications = complications
        self.swipeActions = swipeActions
    }
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    var title: String {
        var suffix = ""
        if community.blocked ?? false {
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
        if complications.contains(.instance), let host = community.host {
            parts.append("@\(host)")
        }
        return parts.joined(separator: " ∙ ")
    }
    
    var body: some View {
        NavigationLink(value: AppRoute.community(community)) {
            HStack(spacing: 10) {
                if community.blocked ?? false {
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
                if complications.contains(.subscribers), let community = community as? any Community2Providing {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(community.subscriberCount))
                            .monospacedDigit()
                        Image(systemName: community.subscriptionTier.systemImage)
                    }
                    .foregroundStyle(community.subscriptionTier.foregroundColor)
                }
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .opacity((community.blocked ?? false) ? 0.5 : 1)
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .draggable(community.actorId) {
            HStack {
                AvatarView(community: community, avatarSize: 24)
                Text(community.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
        // .addSwipeyActions(swipeActions ?? community.swipeActions(confirmDestructive: confirmDestructive))
//        .contextMenu {
//            ForEach(community.menuFunctions(editorTracker: editorTracker)
//            ) { item in
//                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
//            }
//        }
    }
}

#Preview {
    CommunityResultView(Community3.mock())
}
