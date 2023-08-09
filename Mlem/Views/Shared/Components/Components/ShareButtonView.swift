//
//  Save.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

struct ShareButtonView: View {

    // ==== PARAMETERS ==== //

    let accessibilityContext: String

    let share: () -> Void

    // ==== BODY ==== //

    var body: some View {
        Button {
            share()
        } label: {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundStyle(.primary)
                .padding(AppConstants.postAndCommentSpacing)
                .contentShape(Rectangle())
                .fontWeight(.medium) // makes it look a little nicer
        }
        .accessibilityLabel("Share \(accessibilityContext)")
        .accessibilityAction(.default) { share() }
    }
}
