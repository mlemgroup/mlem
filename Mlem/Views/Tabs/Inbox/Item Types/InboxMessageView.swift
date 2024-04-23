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
            .padding(AppConstants.standardSpacing)
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
            .addSwipeyActions(
                message.swipeActions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )
            )
            .contextMenu {
                ForEach(message.menuFunctions(
                    unreadTracker: unreadTracker,
                    editorTracker: editorTracker
                )) { item in
                    MenuButton(menuFunction: item, menuFunctionPopup: .constant(nil))
                }
            }
    }
}
