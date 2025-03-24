//
//  ApiPrivateMessageReportView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiPrivateMessageReportView: ReportApiBacker {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(ReportType.message)
        hasher.combine(privateMessageReport.id)
        return hasher.finalize()
    }
    
    public var id: Int { privateMessageReport.id }
    var reason: String { privateMessageReport.reason }
    var resolved: Bool { privateMessageReport.resolved }
    var published: Date { privateMessageReport.published }
    var updated: Date? { privateMessageReport.updated }
    
    func toPrivateMessageView() -> ApiPrivateMessageView {
        .init(
            privateMessage: privateMessage,
            creator: privateMessageCreator,
            recipient: creator // Only the recipient of the message can report it.
        )
    }
    
    @MainActor
    func createTarget(api: ApiClient, myPersonId: Int) -> ReportTarget {
        .message(
            api.caches.message2.getModel(
                api: api,
                from: toPrivateMessageView(),
                myPersonId: myPersonId
            )
        )
    }
}
