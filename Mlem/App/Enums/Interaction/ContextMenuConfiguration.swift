//
//  ContextMenuConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-21.
//

import Actions
import Foundation

protocol ContextMenuConfiguration {
    var savedContextMenu: [ActionSeed]? { get set }
    var contextMenu: [ActionSeed] { get set }

    static var availableActions: ActionSeedSections { get }
    static var defaultContextMenu: [ActionSeed] { get }
}

extension ContextMenuConfiguration {
    var contextMenu: [ActionSeed] {
        get {
            savedContextMenu ?? Self.defaultContextMenu
        }
        set {
            savedContextMenu = newValue
        }
    }

}
