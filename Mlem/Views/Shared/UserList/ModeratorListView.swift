//
//  ModeratorListView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ModeratorListView: View {
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.notifier) var notifier
    
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @Binding var community: CommunityModel
    let navigationEnabled: Bool
    
    @State var isConfirming: Bool = false
    @State var confirmingUser: UserModel?
    
    var confirmingUserName: String {
        confirmingUser?.name ?? "user"
    }
    
    var canEditModList: Bool {
        siteInformation.myUser?.isAdmin ?? false ||
            siteInformation.moderatedCommunities.contains(community.communityId)
    }
    
    init(community: Binding<CommunityModel>, navigationEnabled: Bool = true) {
        self._community = community
        self.navigationEnabled = navigationEnabled
    }
    
    var body: some View {
        content
            .alert(
                "Remove \(confirmingUserName) as moderator of \(community.name)?",
                isPresented: $isConfirming,
                presenting: confirmingUser
            ) { user in
                Button("Cancel", role: .cancel) {
                    isConfirming = false
                }
                    
                Button("Confirm") {
                    confirmRemoveModerator(user: user)
                }
                .keyboardShortcut(.defaultAction)
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            ModlogNavigationLink(to: community)
            
            Divider()
            
            if let moderators = community.moderators {
                ForEach(moderators, id: \.id) { user in
                    UserListRow(user, complications: [.date], communityContext: community, navigationEnabled: navigationEnabled)
                        .addSwipeyActions(genSwipeyActions(for: user))
                    Divider()
                }
            }
            
            if canEditModList {
                Button {
                    modToolTracker.addModerator(user: nil, to: $community)
                } label: {
                    Label("Add Moderator", systemImage: Icons.add)
                }
                .accessibilityLabel("Add moderator")
                .padding(AppConstants.standardSpacing)
            }
        }
    }
    
    func genSwipeyActions(for user: UserModel) -> SwipeConfiguration {
        // disable swipey actions if user is not admin or moderator
        guard canEditModList else {
            return .init()
        }
        
        var trailingActions: [SwipeAction] = .init()
        
        trailingActions.append(.init(
            symbol: .init(emptyName: Icons.unmod, fillName: Icons.unmodFill), color: .red
        ) {
            confirmingUser = user
            isConfirming = true
        })
        
        return SwipeConfiguration(trailingActions: trailingActions)
    }
    
    func confirmRemoveModerator(user: UserModel) {
        Task {
            _ = await community.updateModStatus(of: user.userId, to: false) { newCommunity in
                community = newCommunity
            }
            await notifier.add(.success("Unmodded \(user.name ?? "user")"))
        }
    }
}
