//
//  ActionRegistry+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-14.
//

import Actions
import Foundation

extension ActionRegistry {
    static let main: ActionRegistry = .init([
        SelectTextAction.self,
        ReportAction.self
    ])
}
