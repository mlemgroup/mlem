//
//  Reply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

struct ReplyButton: View {

    // ==== PARAMETERS ==== //

    let size: CGFloat
    let reply: () -> Void

    init(size: CGFloat, accessibilityContext: String, reply: @escaping () -> Void) {
        self.size = size
        self.reply = reply

        self.replyButtonText = "Reply to \(accessibilityContext)"
    }

    // ==== COMPUTED ==== //

    let replyButtonText: String

    // ==== BODY ==== //

    var body: some View {
        Image(systemName: "arrowshape.turn.up.left.fill")
            .frame(width: size, height: size)
            .foregroundColor(.primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.clear))
            .onTapGesture { reply() }
            .accessibilityLabel(replyButtonText)
            .accessibilityAction(named: replyButtonText) { reply() }

    }
}
