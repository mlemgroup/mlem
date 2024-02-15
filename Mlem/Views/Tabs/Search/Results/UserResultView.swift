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
    
    var body: some View {
        NavigationLink(value: AppRoute.userProfile(user, communityContext: communityContext)) {
            UserRow(user: user, communityContext: communityContext, complications: complications)
        }
        .opacity(user.blocked ? 0.5 : 1)
        .buttonStyle(.plain)
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
        .init(from: .mock())
    )
}
