//
//  ReportAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ReportAction: SimpleLabelAction {
    let entity: any ReportableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let report = ActionSeed("report") { entity in
        switch entity {
        case let entity as any ReportableProviding: ReportAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ReportAction {
    static let label: ActionLabel = .init(
        "Report",
        icon: .lemmy.report,
        color: .themedNegative,
        isDestructive: true
    )
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        if entity.isOwnContent(myPersonId: myPersonId) { return .hidden }
        
        return .enabled
    }
}

// MARK: - Behavior

extension ReportAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.report(entity, community: environment.communityContext))
    }
}
