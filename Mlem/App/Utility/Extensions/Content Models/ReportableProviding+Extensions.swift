//
//  ReportableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 12/08/2024.
//

import MlemMiddleware

extension ReportableProviding {
    func showReportSheet(communityContext: (any CommunityStubProviding)? = nil) {
        NavigationModel.main.openSheet(.report(self, community: communityContext))
    }
    
    func reportAction(communityContext: (any CommunityStubProviding)? = nil) -> BasicAction {
        .init(
            id: "report\(uid)",
            appearance: .report(),
            callback: true ? { self.showReportSheet(communityContext: communityContext) } : nil
        )
    }
}
