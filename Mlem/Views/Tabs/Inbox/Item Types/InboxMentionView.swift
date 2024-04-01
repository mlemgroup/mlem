//
//  InboxMentionView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-22.
//

import SwiftUI

struct InboxMentionView: View {
    @ObservedObject var mention: MentionModel
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var unreadTracker: UnreadTracker

    var body: some View {
        InboxMentionBodyView(mention: mention)
            .addSwipeyActions(
                mention.swipeActions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )
            )
    }
}
