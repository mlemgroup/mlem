//
//  ContextMenu+Community.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI
import QuickSwipes

extension ActionButtons {
    init(community: Community) {
        self.init { _ in
            CommunityActionConfiguration.availableActions.all.compactMap { $0.createAction(community) }
        }
    }
}

extension View {
    func contextMenu(community: Community) -> some View {
        contextMenu {
            CustomizableActionMenu(
                entity: community,
                configuration: \.interactionBar_community,
                customizable: true
            )
        }
    }

    @ViewBuilder
    func quickSwipes(community: Community, configuration: CommunityActionConfiguration, leadingBuffer: SwipeBuffer) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(community) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(community) },
            leadingBuffer: leadingBuffer
        )
    }
}
