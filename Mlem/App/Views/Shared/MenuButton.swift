//
//  MenuButton.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import MlemMiddleware
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
                action: action.callback ?? {}
            ) {
                Label(action.label, systemImage: action.menuIcon)
            }
            .disabled(action.callback == nil)
        } else if let action = action as? ActionGroup {
            switch action.displayMode {
            case .section:
                Section {
                    iterateActions(actions: action.children)
                }
            case .compactSection:
                ControlGroup {
                    iterateActions(actions: action.children)
                }
                .controlGroupStyle(.compactMenu)
            case .disclosure:
                Menu {
                    iterateActions(actions: action.children)
                } label: {
                    Label(action.label, systemImage: action.menuIcon)
                }
            case .popup:
                Text("WIP")
            }
        }
    }
    
    @ViewBuilder
    func iterateActions(actions: [any Action]) -> some View {
        ForEach(actions, id: \.id) { action in
            MenuButton(action: action)
        }
    }
}
