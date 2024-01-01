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
    let communityContext: CommunityModel?
    let showTypeLabel: Bool
    let trackerCallback: (_ item: UserModel) -> Void
    let swipeActions: SwipeConfiguration?
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    init(
        _ user: UserModel,
        communityContext: CommunityModel? = nil,
        showTypeLabel: Bool = false,
        swipeActions: SwipeConfiguration? = nil,
        trackerCallback: @escaping (_ item: UserModel) -> Void = { _ in }
    ) {
        self.user = user
        self.communityContext = communityContext
        self.showTypeLabel = showTypeLabel
        self.swipeActions = swipeActions
        self.trackerCallback = trackerCallback
    }
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    var title: String {
        if user.blocked {
            return "\(user.displayName) ∙ Blocked"
        } else {
            return user.displayName
        }
    }
    
    var caption: String {
        if let host = user.profileUrl.host {
            if showTypeLabel {
                return "User ∙ @\(host)"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return "@\(host) ∙ \(dateFormatter.string(from: user.creationDate))"
            }
        }
        return "Unknown instance"
    }
    
    var body: some View {
        NavigationLink(value: AppRoute.userProfile(user)) {
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
                if showTypeLabel {
                    HStack(spacing: 5) {
                        if let commentCount = user.commentCount {
                            Text(abbreviateNumber(commentCount))
                                .monospacedDigit()
                            Image(systemName: Icons.replies)
                        }
                    }
                    .foregroundStyle(.secondary)
                } else {
                    if let commentCount = user.commentCount, let postCount = user.postCount {
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
                    }
                }
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
            ForEach(user.menuFunctions(trackerCallback)) { item in
                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
            }
        }
    }
}

#Preview {
    UserResultView(
        .init(from: .mock()),
        showTypeLabel: true
    )
}
