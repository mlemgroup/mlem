//
//  Share.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ShareButton: View {

    // ==== PARAMETERS ==== //

    let size: CGFloat
    let share: () -> Void

    init(size: CGFloat, accessibilityContext: String, share: @escaping () -> Void) {
        self.size = size
        self.share = share

        self.shareButtonText = "Share \(accessibilityContext)"
    }

    // ==== COMPUTED ==== //

    let shareButtonText: String

    // ==== BODY ==== //

    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .frame(width: size, height: size)
            .foregroundColor(.primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.clear))
            .onTapGesture {
                share()
            }
            .accessibilityRemoveTraits(.isImage)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(shareButtonText)
            .accessibilityAction(named: shareButtonText) { share() }
    }
}
