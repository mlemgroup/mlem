//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import SwiftUI

struct EllipsisMenu: View {
    @Environment(Palette.self) private var palette: Palette
    
    @ActionBuilder let actions: () -> [any Action]
    let size: CGFloat
    
    // See comments in `View+ContextMenu` for why `@autoclosure` is used here
    init(size: CGFloat, @ActionBuilder actions: @escaping () -> [any Action]) {
        self.actions = actions
        self.size = size
    }
    
    var body: some View {
        Menu {
            MenuButtons(actions: actions)
        } label: {
            Image(systemName: Icons.menu)
                .frame(width: 24, height: size)
                .contentShape(.rect)
        }
        .popupAnchor()
        .buttonStyle(.empty)
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
}
