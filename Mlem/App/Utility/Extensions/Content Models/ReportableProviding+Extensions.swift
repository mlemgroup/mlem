//
//  ReportableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware

extension ReportableProviding {
    @MainActor
    func showReportSheet(communityContext: (any CommunityStubProviding)? = nil) {
        NavigationModel.main.openSheet(.report(self, community: communityContext))
    }
    
    func reportAction(appState: AppState, communityContext: (any CommunityStubProviding)? = nil) -> BasicAction {
        .init(
            id: "report\(uid)",
            appearance: .report(),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.showReportSheet(communityContext: communityContext) } : nil
        )
    }
}
