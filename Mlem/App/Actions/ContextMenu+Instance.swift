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
    .openInBrowser,
    .share,
    .block
]

extension View {
    @ViewBuilder
    func contextMenu(instance: (any InstanceStubProviding)?) -> some View {
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
