//
//  ReportAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ReportAction: ConfigurableAction {
    static let configurationKey = "report"
    
    static let label: ActionLabel = .init(
        "Report",
        icon: .lemmy.report,
        isDestructive: true
    )
    
    let entity: any ReportableProviding
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        var label = Self.label
        
        guard let myPersonId = entity.api.myPerson?.id else {
            return label
        }
        
        if entity.isOwnContent(myPersonId: myPersonId) {
            label.visibility = .hidden
        }
        
        return label
    }
    
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.report(entity, community: environment.communityContext))
    }
}

extension ReportAction: MessageConfigurableAction {
    init(_ message: any Message1Providing) { self.entity = message }
}
