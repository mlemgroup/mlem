//
//  Save.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

struct SaveButtonView: View {

    // ==== PARAMETERS ==== //

    let isSaved: Bool
    let accessibilityContext: String

    let save: () -> Void

    // ==== COMPUTED ==== //

    // this needs to be computed because it changes depending on button state
    var saveButtonText: String { isSaved ? "Unsave \(accessibilityContext)" : "Save \(accessibilityContext)" }

    // ==== BODY ==== //

    var body: some View {
        Button {
            save()
        } label: {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundColor(isSaved ? .white : .primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(isSaved ? .saveColor : .clear))
                .padding(AppConstants.postAndCommentSpacing)
                .contentShape(Rectangle())
                .fontWeight(.medium) // makes it look a little nicer
        }
        .accessibilityLabel(saveButtonText)
        .accessibilityAction(.default) { save() }
    }
}
