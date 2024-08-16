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
            appearance: .init(
                label: "Report",
                isOn: false,
                isDestructive: true,
                color: Palette.main.negative,
                icon: Icons.moderationReport
            ),
            callback: api.canInteract ? { self.showReportSheet(communityContext: communityContext) } : nil
        )
    }
}
