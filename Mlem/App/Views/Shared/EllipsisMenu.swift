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
    
    let actions: [any Action]
    let size: CGFloat
    
    var body: some View {
        Menu {
            ForEach(actions, id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            Image(systemName: Icons.menu)
                .frame(width: 24, height: size)
                .foregroundColor(actions.isEmpty ? palette.secondary : palette.primary)
                .contentShape(.rect)
        }
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
}
