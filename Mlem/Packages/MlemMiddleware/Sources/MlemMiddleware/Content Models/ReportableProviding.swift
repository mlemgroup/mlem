//
//  ReportableProviding.swift
//
//
//  Created by Sjmarf on 23/07/2024.
//

import Foundation

public protocol ReportableProviding: ContentIdentifiable {
    func isOwnContent(myPersonId: Int) -> Bool
    func report(reason: String) async throws
}
