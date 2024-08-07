//
//  View+ContextMenu.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

// This setup avoids actually generating the array of actions until the context menu itself
// is opened, as long as the actions are generated directly in the `.contextMenu` call like
// `.contextMenu(actions: post.menuActions()). This is achieved using `@autoclosure`.
// This can have performance benefits in certain situations.

extension View {
    @ViewBuilder
    func contextMenu(actions: @autoclosure @escaping () -> [any Action]) -> some View {
        contextMenu {
            // Having a separate struct here is necessary - if `ForEach` is used directly here, `actions()` gets called early.
            MenuButtons(actions: actions)
        }
    }
}

struct MenuButtons: View {
    let actions: () -> [any Action]

    var body: some View {
        ForEach(actions(), id: \.id) { action in
            MenuButton(action: action)
        }
    }
}
