//
//  ContextMenu+Message.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .reply,
    .selectText,
    .report,
    .edit,
    .delete
]

extension View {
    func contextMenu(message: Message) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(message) }
            }
        }
    }
}
