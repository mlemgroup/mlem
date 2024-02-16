//
//  UserResultView.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import SwiftUI

enum UserComplication: CaseIterable {
    case type, instance, date, posts, comments
}

extension [UserComplication] {
    static let withTypeLabel: [UserComplication] = [.type, .instance, .comments]
    static let withoutTypeLabel: [UserComplication] = [.instance, .date, .posts, .comments]
    static let instanceOnly: [UserComplication] = [.instance]
}

struct UserResultView: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    let user: UserModel
    let communityContext: CommunityModel?
    let trackerCallback: (_ item: UserModel) -> Void
    let swipeActions: SwipeConfiguration?
    let complications: [UserComplication]
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    @EnvironmentObject var editorTracker: EditorTracker
    
    init(
        _ user: UserModel,
        complications: [UserComplication] = .withoutTypeLabel,
        communityContext: CommunityModel? = nil,
        swipeActions: SwipeConfiguration? = nil,
        trackerCallback: @escaping (_ item: UserModel) -> Void = { _ in }
    ) {
        self.user = user
        self.complications = complications
        self.communityContext = communityContext
        self.swipeActions = swipeActions
        self.trackerCallback = trackerCallback
    }
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
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
        NavigationLink(value: AppRoute.userProfile(user, communityContext: communityContext)) {
            HStack(spacing: 10) {
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
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .opacity(user.blocked ? 0.5 : 1)
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
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
        .addSwipeyActions(swipeActions ?? .init())
        .contextMenu {
            ForEach(user.menuFunctions(trackerCallback, editorTracker: editorTracker)) { item in
                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
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

#Preview {
    UserResultView(
        .init(from: .mock())
    )
}
