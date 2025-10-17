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
    .selectText,
    .report,
    .edit
]

extension View {
    func contextMenu(message: any Message1Providing) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(message) }
            }
        }
    }
}
