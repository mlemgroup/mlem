//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import SwiftUI

struct EllipsisMenu: View {
    @Environment(Palette.self) var palette: Palette
    
    let actions: ActionGroup
    let size: CGFloat
    
    var body: some View {
        Menu {
            ForEach(actions.children, id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            Image(systemName: Icons.menu)
                .frame(width: 24, height: size)
                .foregroundColor(actions.children.isEmpty ? palette.secondary : palette.primary)
                .contentShape(.rect)
        }
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
}