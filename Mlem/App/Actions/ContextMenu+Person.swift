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
    .appointModerator,
    .appointAdmin
]

extension ActionButtons {
    init(person: any Person1Providing) {
        self.init { _ in
            seeds.compactMap { $0.createAction(person) }
        }
    }
}

extension View {
    func contextMenu(person: any Person1Providing) -> some View {
        contextMenu {
            ActionButtons(person: person)
        }
    }
}
