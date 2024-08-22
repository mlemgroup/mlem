//
//  MenuButton.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

struct MenuButton: View {
    @Environment(NavigationLayer.self) var navigation
    
    let action: any Action
    
    init(action: any Action) {
        self.action = action
    }
    
    var body: some View {
        if let action = action as? BasicAction {
            Button(
                action.appearance.label,
                systemImage: action.appearance.menuIcon,
                role: action.appearance.isDestructive ? .destructive : nil,
                action: { action.callbackWithConfirmation(navigation: navigation) }
            )
            .disabled(action.disabled)
        } else if let action = action as? ShareAction {
            ShareLink(item: action.url)
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
                    Label(action.appearance.label, systemImage: action.appearance.menuIcon)
                }
            case .popup:
                Button(
                    action.appearance.label,
                    systemImage: action.appearance.menuIcon,
                    role: action.appearance.isDestructive ? .destructive : nil,
                    action: {
                        navigation.showPopup(action)
                    }
                )
                .disabled(action.disabled)
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
