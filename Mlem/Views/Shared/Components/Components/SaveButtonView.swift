//
//  SaveButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Dependencies
import SwiftUI

struct SaveButtonView: View {
    @Dependency(\.hapticManager) var hapticManager
    
    let content: any InteractableContent
    let accessibilityContext: String

    // this needs to be computed because it changes depending on button state
    var saveButtonText: String { content.isSaved ? "Unsave \(accessibilityContext)" : "Save \(accessibilityContext)" }

    var body: some View {
        Button {
            hapticManager.play(haptic: .success, priority: .low)
            content.toggleSave()
        } label: {
            Image(systemName: content.isSaved ? Icons.saveFill : Icons.save)
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundColor(content.isSaved ? .white : .primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(content.isSaved ? .saveColor : .clear))
                .contentShape(Rectangle())
                .fontWeight(.medium) // makes it look a little nicer
        }
        .accessibilityLabel(saveButtonText)
        .accessibilityAction(.default) {
            hapticManager.play(haptic: .success, priority: .low)
            content.toggleSave()
        }
        .buttonStyle(.plain)
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
