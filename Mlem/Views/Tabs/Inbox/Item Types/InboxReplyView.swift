//
//  InboxReplyView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-21.
//

import SwiftUI

struct InboxReplyView: View {
    @ObservedObject var reply: ReplyModel
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker

    var body: some View {
        InboxReplyBodyView(reply: reply)
            .addSwipeyActions(
                reply.swipeActions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )
            )
    }
}
