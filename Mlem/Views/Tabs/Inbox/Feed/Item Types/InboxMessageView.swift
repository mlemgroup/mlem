//
//  InboxMessageView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-22.
//

import SwiftUI

struct InboxMessageView: View {
    @ObservedObject var message: MessageModel
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker

    var body: some View {
        InboxMessageBodyView(message: message)
            .addSwipeyActions(
                message.swipeActions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )
            )
    }
}
