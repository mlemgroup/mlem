//
//  MenuButton.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

struct MenuButton: View {
    let action: any Action
    
    init(action: any Action) {
        self.action = action
    }
    
    var body: some View {
        if let action = action as? BasicAction {
            Button(
                role: action.isDestructive ? .destructive : nil,
                action: action.callback ?? { }
            ) {
                Label(action.label, systemImage: action.menuIcon)
            }
            .disabled(action.callback == nil)
        }
    }
}
