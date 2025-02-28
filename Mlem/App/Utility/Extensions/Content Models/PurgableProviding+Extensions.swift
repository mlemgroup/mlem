//
//  PurgableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-27.
//

import Foundation
import MlemMiddleware

extension PurgableProviding {
    @MainActor
    func showPurgeSheet() {
        NavigationModel.main.openSheet(.purge(self))
    }
    
    func purgeAction(appState: AppState) -> BasicAction {
        .init(
            id: "purge\(uid)",
            appearance: .purge(),
            callback: (api.canInteract(appState: appState) && api.isAdmin) ? showPurgeSheet : nil
        )
    }
}
