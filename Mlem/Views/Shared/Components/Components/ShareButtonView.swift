//
//  ShareButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

struct ShareButtonView: View {
    // ==== PARAMETERS ==== //

    let accessibilityContext: String

    let url: URL?

    // ==== BODY ==== //

    var body: some View {
        if let url {
            ShareLink(item: url) {
                label.foregroundColor(.primary)
            }
        } else {
            label.foregroundColor(.secondary)
        }
    }
    
    var label: some View {
        Image(systemName: AppConstants.shareSymbolName)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .padding(AppConstants.postAndCommentSpacing)
            .contentShape(Rectangle())
            .fontWeight(.medium) // makes it look a little nicer
    }
}
