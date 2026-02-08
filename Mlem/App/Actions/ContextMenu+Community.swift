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
    .goToInstance,
    .copyName,
    .share,
    .block
]

extension ActionButtons {
    init(community: any Community1Providing) {
        self.init { _ in
            seeds.compactMap { $0.createAction(community) }
        }
    }
}

extension View {
    func contextMenu(community: any Community1Providing) -> some View {
        contextMenu {
            ActionButtons(community: community)
        }
    }
}
