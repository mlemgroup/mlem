//
//  RegistrationApplication+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-14.
//

import Foundation
import MlemMiddleware

extension RegistrationApplication {
    @MainActor
    func showDenialSheet() {
        NavigationModel.main.openSheet(.denyApplication(self))
    }
    
    @ActionBuilder
    func menuActions() -> [any Action] {
        if !resolution.isDenied {
            denyAction()
        }
    }
    
    func denyAction() -> BasicAction {
        .init(
            id: "denyApplication\(id)",
            appearance: .init(
                label: "Deny",
                color: .themedNegative,
                icon: Icons.failureCircle
            ),
            callback: showDenialSheet
        )
    }
}
