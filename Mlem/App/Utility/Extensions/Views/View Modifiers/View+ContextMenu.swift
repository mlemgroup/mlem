//
//  View+ContextMenu.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

// This setup avoids actually generating the array of actions until the context menu itself
// is opened. This can have performance benefits in certain situations.

extension View {
    @ViewBuilder
    func contextMenu(@ActionBuilder actions: @escaping () -> [any Action]) -> some View {
        contextMenu {
            // Having a proper view here is necessary - if `ForEach` is used directly, `actions()` gets called early.
            MenuButtons(actions: actions)
        }
    }
}

struct MenuButtons: View {
    @ActionBuilder let actions: () -> [any Action]

    var body: some View {
        ForEach(actions(), id: \.id) { action in
            MenuButton(action: action)
        }
    }
}
