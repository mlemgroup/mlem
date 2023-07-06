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
        HStack(spacing: 2) { // TODO: app constants
            Image(systemName: replyIcon)
            Text(String(replyCount))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(replyButtonText)
        .accessibilityAction(named: replyButtonText) { replyCallback() }
        .onTapGesture { replyCallback() }

    }
    
    // MARK: Helpers
    
    func replyCallback() {
        if let reply = reply {
            reply()
        }
    }
}
