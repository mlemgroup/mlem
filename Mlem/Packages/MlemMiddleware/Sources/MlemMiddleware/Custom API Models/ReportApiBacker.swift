//
//  ReportApiBacker.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

/// This protocol is conformed to be ``ApiCommentReplyView`` and ``ApiPersonMentionView``.
protocol ReportApiBacker: CacheIdentifiable, Identifiable where ID == Int {
    var resolver: ApiPerson? { get }
    var creator: ApiPerson { get }
    var reason: String { get }
    var resolved: Bool { get }
    var published: Date { get }
    var updated: Date? { get }
    
    @MainActor
    func createTarget(api: ApiClient, myPersonId: Int) -> ReportTarget
}
