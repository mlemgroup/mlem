//
//  Reply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

struct ReplyButton: View {

    // MARK: Parameters

    let replyCount: Int
    let reply: (() -> Void)?

    init(replyCount: Int, accessibilityContext: String, reply: (() -> Void)?) {
        self.replyCount = replyCount
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
        }
        .accessibilityLabel(replyButtonText)
        .frame(width: AppConstants.barIconHitbox, height: AppConstants.barIconHitbox)
    }
    
    // MARK: Helpers
    
    func replyCallback() {
        if let reply = reply {
            reply()
        }
    }
}
