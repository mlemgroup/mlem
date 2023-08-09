//
//  Reply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

struct ReplyButtonView: View {

    // MARK: Parameters

    let reply: (() -> Void)?

    init(accessibilityContext: String, reply: (() -> Void)?) {
        self.reply = reply
        
        self.replyIcon = reply == nil ? "quote.bubble.left" : "arrowshape.turn.up.left"
        self.replyButtonText = "Reply to \(accessibilityContext)"
    }

    // MARK: Computed

    let replyButtonText: String
    let replyIcon: String

    // MARK: Body

    var body: some View {
        Button {
            replyCallback()
        } label: {
            Image(systemName: replyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding) // this double padding looks funky but it's for consistency w/ other buttons
                .padding(AppConstants.postAndCommentSpacing)
                .contentShape(Rectangle())
                .fontWeight(.medium) // makes it look a little nicer
        }
        .accessibilityLabel(replyButtonText)
        .accessibilityAction(.default) { replyCallback() }
        .frame(width: AppConstants.barIconHitbox, height: AppConstants.barIconHitbox)
        .buttonStyle(.plain)
    }
    
    // MARK: Helpers
    
    func replyCallback() {
        if let reply = reply {
            reply()
        }
    }
}
