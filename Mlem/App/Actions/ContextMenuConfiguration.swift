//
//  ContextMenuConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-14.
//

import Actions
import Foundation
import SwiftUI

struct ContextMenuConfiguration {
    let actions: [ConfigurableAction.Type]
}

extension ContextMenuConfiguration: Codable {
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.actions = try container.decode([ActionToken].self).map(\.actionType)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: actions.map(ActionToken.init))
    }
}
