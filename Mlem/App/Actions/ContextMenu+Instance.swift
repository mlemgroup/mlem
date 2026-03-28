//
//  ContextMenu+Instance.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-15.
//

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .visit,
    .logIn,
    .signUp,
    .openInBrowser,
    .share,
    .block
]

extension View {
    @ViewBuilder
    func contextMenu(instance: Instance?) -> some View {
        if let instance {
            contextMenu {
                ActionButtons { _ in
                    seeds.compactMap { $0.createAction(instance) }
                }
            }
        } else {
            self
        }
    }
}

extension ToolbarEllipsisMenu {
    init(instance: Instance) where Content == ActionButtons {
        self.init {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(instance) }
            }
        }
    }
}
