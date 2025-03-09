//
//  EllipsisMenu.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import SwiftUI

struct EllipsisMenu: View {
    @State @ActionBuilder var actions: () -> [any Action]
    let systemImage: String
    let size: CGFloat
    
    init(systemImage: String = Icons.menu, size: CGFloat, @ActionBuilder actions: @escaping () -> [any Action]) {
        self.systemImage = systemImage
        self.actions = actions
        self.size = size
    }
    
    var body: some View {
        Menu {
            MenuButtons(actions: actions)
        } label: {
            Image(systemName: systemImage)
                .frame(width: 24, height: size)
                .contentShape(.rect)
        }
        .popupAnchor()
        .buttonStyle(.empty)
        .onTapGesture {} // prevent NavigationLink from disabling menu (thanks Swift)
    }
}
