//
//  ReportableProviding.swift
//
//
//  Created by Sjmarf on 23/07/2024.
//

import Foundation

public protocol ReportableProviding: OwnershipProviding {
    func report(reason: String) async throws
}
