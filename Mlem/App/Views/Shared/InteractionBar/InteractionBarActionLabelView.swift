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
            .padding(Constants.main.barIconPadding)
            .foregroundColor(appearance.isOn ? palette.selectedInteractionBarItem : palette.primary)
            .background(appearance.isOn ? appearance.color : .clear, in: .rect(cornerRadius: Constants.main.barIconCornerRadius))
            .contentShape(Rectangle())
    }
}
