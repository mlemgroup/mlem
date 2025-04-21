//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import Icons
import SwiftUI

struct EllipsisMenu: View {
    @State @ActionBuilder var actions: () -> [any Action]
    let icon: Icon
    let size: CGFloat
    
    init(icon: Icon = .general.menu, size: CGFloat, @ActionBuilder actions: @escaping () -> [any Action]) {
        self.icon = icon
        self.actions = actions
        self.size = size
    }
    
    var body: some View {
        Menu {
            MenuButtons(actions: actions)
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
