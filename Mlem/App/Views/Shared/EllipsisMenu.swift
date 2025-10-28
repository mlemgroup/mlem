//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Actions
import Foundation
import Icons
import SwiftUI

struct EllipsisMenu<Content: View>: View {
    let content: Content
    let icon: Icon
    let size: CGFloat
    
    init(icon: Icon = .general.menu, size: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon
        self.size = size
        self.content = content()
    }
    
    var body: some View {
        Menu {
            content
        } label: {
            Image(icon: icon)
                .frame(width: 24, height: size)
                .contentShape(.rect)
        }
        .popupAnchor()
        .buttonStyle(.empty)
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        @ActionBuilder actions: @escaping () -> [any Action]
    ) where Content == MenuButtons {
        self.icon = icon
        self.size = size

        self.content = MenuButtons(actions: actions)
    }
}
