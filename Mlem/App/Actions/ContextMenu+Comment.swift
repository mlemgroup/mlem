//
//  ContextMenu+Comment.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .selectText,
    .share,
    .report,
    .blockCreator,
    .edit,
    .delete
]

extension View {
    func contextMenu(comment: any Comment1Providing) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(comment) }
            }
        }
    }
}
