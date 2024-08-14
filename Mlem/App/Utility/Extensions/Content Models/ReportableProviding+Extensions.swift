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
            isOn: false,
            label: "Report",
            color: Palette.main.negative,
            isDestructive: true,
            icon: Icons.moderationReport,
            callback: api.canInteract ? { self.showReportSheet(communityContext: communityContext) } : nil
        )
    }
}
