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

extension Array where Element == CommunityComplication {
    static let withTypeLabel: [CommunityComplication] = [.type, .instance, .subscribers]
    static let withoutTypeLabel: [CommunityComplication] = [.instance, .subscribers]
    static let instanceOnly: [CommunityComplication] = [.instance]
}

struct CommunityResultView: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    let community: CommunityModel
    let trackerCallback: (_ item: CommunityModel) -> Void
    let swipeActions: SwipeConfiguration?
    let complications: [CommunityComplication]

    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    @EnvironmentObject var editorTracker: EditorTracker
    
    init(
        _ community: CommunityModel,
        complications: [CommunityComplication] = .withoutTypeLabel,
        swipeActions: SwipeConfiguration? = nil,
        trackerCallback: @escaping (_ item: CommunityModel) -> Void = { _ in }
    ) {
        self.community = community
        self.complications = complications
        self.swipeActions = swipeActions
        self.trackerCallback = trackerCallback
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
                if complications.contains(.subscribers), let subscriberCount = community.subscriberCount {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(subscriberCount))
                            .monospacedDigit()
                        Image(systemName: subscriberCountIcon)
                    }
                    .foregroundStyle(subscriberCountColor)
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
        .draggable(community.communityUrl) {
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
        .addSwipeyActions(swipeActions ?? community.swipeActions(trackerCallback, confirmDestructive: confirmDestructive))
        .contextMenu {
            ForEach(
                community.menuFunctions(
                    editorTracker: editorTracker,
                    trackerCallback
                )
            ) { item in
                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
            }
        }
    }
}

#Preview {
    CommunityResultView(
        .init(from: .mock())
    )
}
