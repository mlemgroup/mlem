//
//  ReportableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware

extension ReportableProviding {
    @MainActor
    func showReportSheet(communityContext: Community? = nil) {
        NavigationModel.main.openSheet(.report(self, community: communityContext))
    }
    
    func reportAction(appState: AppState, communityContext: Community? = nil) -> BasicAction {
        .init(
            id: "report\(uid)",
            appearance: .report(),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.showReportSheet(communityContext: communityContext) } : nil
        )
    }
}
