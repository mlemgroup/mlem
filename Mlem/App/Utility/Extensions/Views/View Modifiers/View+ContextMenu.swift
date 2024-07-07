//
//  View+ContextMenu.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

extension View {
    func contextMenu(actions: [any Action]) -> some View {
        contextMenu {
            ForEach(actions, id: \.id) { action in
                MenuButton(action: action)
            }
        }
    }
    
    func contextMenu(actionGroup: ActionGroup) -> some View {
        contextMenu {
            ForEach(actionGroup.children, id: \.id) { action in
                MenuButton(action: action)
            }
        }
    }
}
