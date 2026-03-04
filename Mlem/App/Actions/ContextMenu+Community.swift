//
//  ContextMenu+Community.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI

extension ActionButtons {
    init(community: any Community1Providing) {
        self.init { _ in
            CommunityActionConfiguration.availableActions.all.compactMap { $0.createAction(community) }
        }
    }
}

extension View {
    func contextMenu(community: any Community1Providing) -> some View {
        contextMenu {
            ActionButtons(community: community)
        }
    }

    @ViewBuilder
    func quickSwipes(community: any Community1Providing, configuration: CommunityActionConfiguration) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(community) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(community) }
        )
    }
}
