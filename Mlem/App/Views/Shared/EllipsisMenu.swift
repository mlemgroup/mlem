//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import SwiftUI

enum EllipsisMenuStyle {
    case standard
    case compact
    
    var size: CGFloat {
        switch self {
        case .standard: 24
        case .compact: 22
        }
    }
}

struct EllipsisMenu: View {
    @Environment(Palette.self) private var palette: Palette
    
    @ActionBuilder let actions: () -> [any Action]
    let style: EllipsisMenuStyle
    
    // See comments in `View+ContextMenu` for why `@autoclosure` is used here
    init(style: EllipsisMenuStyle, @ActionBuilder actions: @escaping () -> [any Action]) {
        self.actions = actions
        self.style = style
    }
    
    var body: some View {
        Menu {
            MenuButtons(actions: actions)
        } label: {
            label
        }
        .popupAnchor()
        .buttonStyle(EmptyButtonStyle())
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
    
    @ViewBuilder
    var label: some View {
        switch style {
        case .standard:
            Image(systemName: Icons.menu)
                .frame(width: style.size, height: style.size)
                .contentShape(.rect)
                .foregroundStyle(palette.accent)
                .background {
                    Circle().fill(.ultraThinMaterial)
                }
        case .compact:
            Image(systemName: Icons.menu)
                .frame(width: style.size, height: style.size)
                .contentShape(.rect)
                .foregroundStyle(palette.primary)
        }
    }
}
