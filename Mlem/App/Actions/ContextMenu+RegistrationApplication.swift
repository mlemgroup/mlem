//
//  ContextMenu+RegistrationApplication.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-08.
//

import Actions
import Icons
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .approveApplication,
    .denyApplication
]

extension View {
    func contextMenu(application: RegistrationApplication) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(application) }
            }
        }
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        application: RegistrationApplication
    ) where Content == ActionButtons {
        self.icon = icon
        self.size = size

        self.content = ActionButtons { _ in
            seeds.compactMap { $0.createAction(application) }
        }
    }
}
