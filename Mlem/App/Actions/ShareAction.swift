//
//  ShareAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ShareAction: SimpleLabelAction {
    let entity: any Sharable
}

// MARK: - Configurability

extension ActionSeed {
    static let share = ActionSeed("share") { entity in
        switch entity {
        case let entity as any Sharable: ShareAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ShareAction {
    static let label: ActionLabel = .init(
        "Share...",
        icon: .general.share,
        color: .themedColorfulAccent(3)
    )
}

// MARK: - Behavior

extension ShareAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        let url: URL? = switch Settings.get(\.links_shareMode) {
        case .myInstance: entity.url()
        case .originalInstance: entity.actorId.url
        case .lemmyverse: entity.lemmyverseUrl
        case .askEveryTime: nil
        }
        if let url, let navigation = environment.navigation {
            if case .actionSheet = navigation.root {
                navigation.dismissSheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    NavigationModel.main.shareInfo = .init(url: url, actions: entity.shareSheetActions())
                }
            } else {
                navigation.model?.shareInfo = .init(url: url, actions: entity.shareSheetActions())
            }
        } else {
            environment.navigation?.openSheet(.shareInstancePicker(entity))
        }
    }
}
