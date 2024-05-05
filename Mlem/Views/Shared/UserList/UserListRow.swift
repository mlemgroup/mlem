//
//  UserListRow.swift
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

struct UserListRow: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    let user: UserModel
    let communityContext: CommunityModel?
    let showBlockStatus: Bool
    let trackerCallback: (_ item: UserModel) -> Void
    let swipeActions: SwipeConfiguration?
    let complications: [UserComplication]
    let navigationEnabled: Bool
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
    init(
        _ user: UserModel,
        complications: [UserComplication] = .withoutTypeLabel,
        showBlockStatus: Bool = true,
        communityContext: CommunityModel? = nil,
        swipeActions: SwipeConfiguration? = nil,
        navigationEnabled: Bool = true,
        trackerCallback: @escaping (_ item: UserModel) -> Void = { _ in }
    ) {
        self.user = user
        self.complications = complications
        self.showBlockStatus = showBlockStatus
        self.communityContext = communityContext
        self.swipeActions = swipeActions
        self.navigationEnabled = navigationEnabled
        self.trackerCallback = trackerCallback
    }
    
    var body: some View {
        userRow
            .opacity((user.blocked && showBlockStatus) ? 0.5 : 1)
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
            .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
            .addSwipeyActions(swipeActions ?? .init())
            .contextMenu {
                ForEach(user.menuFunctions(trackerCallback, modToolTracker: modToolTracker)) { item in
                    MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                }
            }
    }
    
    @ViewBuilder
    var userRow: some View {
        if navigationEnabled {
            NavigationLink(value: AppRoute.userProfile(user, communityContext: communityContext)) {
                UserListRowBody(
                    user: user,
                    communityContext: communityContext,
                    complications: complications,
                    showBlockStatus: showBlockStatus,
                    navigationEnabled: true
                )
            }
        } else {
            UserListRowBody(
                user: user,
                communityContext: communityContext,
                complications: complications,
                showBlockStatus: showBlockStatus,
                navigationEnabled: false
            )
        }
    }
}

#Preview {
    UserListRow(
        .init(from: .mock())
    )
}
