//
//  ContextMenu+Community.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .newPost,
    .subscribe,
    .favorite,
    .goToInstance,
    .copyName,
    .share,
    .block,
    .remove,
    .purge
]

extension ActionButtons {
    init(community: Community) {
        self.init { _ in
            seeds.compactMap { $0.createAction(community) }
        }
    }
}

extension View {
    func contextMenu(community: Community) -> some View {
        contextMenu {
            ActionButtons(community: community)
        }
    }
}
