//
//  CommunityListRow.swift
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

struct CommunityListRow: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    let community: CommunityModel
    let trackerCallback: (_ item: CommunityModel) -> Void
    let swipeActions: SwipeConfiguration?
    let complications: [CommunityComplication]
    let navigationEnabled: Bool
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
    @EnvironmentObject var editorTracker: EditorTracker
    
    init(
        _ community: CommunityModel,
        complications: [CommunityComplication] = .withoutTypeLabel,
        swipeActions: SwipeConfiguration? = nil,
        navigationEnabled: Bool = true,
        trackerCallback: @escaping (_ item: CommunityModel) -> Void = { _ in }
    ) {
        self.community = community
        self.complications = complications
        self.swipeActions = swipeActions
        self.navigationEnabled = navigationEnabled
        self.trackerCallback = trackerCallback
    }
    
    var body: some View {
        communityRow
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
            .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
            .addSwipeyActions(swipeActions ?? community.swipeActions(trackerCallback, menuFunctionPopup: $menuFunctionPopup))
            .contextMenu {
                ForEach(
                    community.menuFunctions(
                        editorTracker: editorTracker,
                        trackerCallback
                    )
                ) { item in
                    MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                }
            }
    }
    
    @ViewBuilder
    var communityRow: some View {
        if navigationEnabled {
            NavigationLink(value: AppRoute.community(community)) {
                CommunityListRowBody(community: community, complications: complications, navigationEnabled: true)
            }
        } else {
            CommunityListRowBody(community: community, complications: complications, navigationEnabled: false)
        }
    }
}

#Preview {
    CommunityListRow(
        .init(from: .mock())
    )
}
