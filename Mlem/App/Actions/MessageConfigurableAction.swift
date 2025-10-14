//
//  PostConfigurable.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import ComponentViews
import MlemMiddleware
import SwiftUI

protocol MessageConfigurableAction: ConfigurableAction {
    init(_ message: any Message1Providing)
}

extension EnvironmentValues {
    @Entry var messageContextMenuConfiguration: ContextMenuConfiguration = .init(actions: [
        SelectTextAction.self,
        ReportAction.self
    ])
}

extension View {
    @ViewBuilder
    func contextMenu(message: any Message1Providing) -> some View {
        contextMenu {
            ActionButtons { environment in
                environment.messageContextMenuConfiguration.actions.compactMap {
                    ($0 as? MessageConfigurableAction.Type)?(message)
                }
            }
        }
    }
}
