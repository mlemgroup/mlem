//
//  InteractionBarActionView.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import SwiftUI

struct InteractionBarActionLabelView: View {
    static let unweightedSymbols: Set<String> = [Icons.upvote, Icons.downvote]
    
    @Environment(Palette.self) private var palette
    
    let appearance: ActionAppearance
    
    init(_ appearance: ActionAppearance) {
        self.appearance = appearance
    }
    
    var body: some View {
        Image(systemName: appearance.barIcon)
            .resizable()
            .fontWeight(Self.unweightedSymbols.contains(appearance.barIcon) ? .regular : .medium)
            .symbolVariant(appearance.isOn ? .fill : .none)
            .scaledToFit()
            .frame(width: Constants.main.barIconSize, height: Constants.main.barIconSize)
            .frame(width: Constants.main.barIconHitbox, height: Constants.main.barIconHitbox)
            .foregroundColor(appearance.isOn ? palette.selectedInteractionBarItem : palette.accent)
            .background {
                if appearance.isOn {
                    Circle().foregroundStyle(appearance.color)
                } else {
                    Circle().foregroundStyle(.ultraThinMaterial)
                }
            }
            .contentShape(Rectangle())
    }
}
