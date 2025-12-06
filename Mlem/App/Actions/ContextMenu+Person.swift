//
//  ContextMenu+Person.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .goToInstance,
    .copyName,
    .share,
    .sendMessage,
    .block,
    .openModlog,
    .ban,
    .purge,
    .appointModerator
]

extension View {
    func contextMenu(person: any Person1Providing) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(person) }
            }
        }
    }
}
