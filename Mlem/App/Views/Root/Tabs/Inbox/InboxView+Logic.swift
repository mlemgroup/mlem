//
//  InboxView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import Foundation

extension InboxView {
    var taskId: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstApi)
        hasher.combine(showRead)
        return hasher.finalize()
    }
    
    func removeAll() {
        replies.removeAll()
        mentions.removeAll()
        messages.removeAll()
        combined.removeAll()
    }
    
    func loadReplies() async {
        loadingState = .loading
        do {
            async let replies = appState.firstApi.getReplies(page: 1, limit: 50, unreadOnly: !showRead)
            async let mentions = appState.firstApi.getMentions(page: 1, limit: 50, unreadOnly: !showRead)
            async let messages = appState.firstApi.getMessages(page: 1, limit: 50, unreadOnly: !showRead)
            try await (appState.firstSession as? UserSession)?.unreadCount?.refresh()
            self.replies = try await replies
            self.mentions = try await mentions
            self.messages = try await messages
            combined = (self.replies + self.mentions + self.messages).sorted(by: { $0.created > $1.created })
            loadingState = .done
        } catch {
            handleError(error)
            loadingState = .idle
        }
    }
}
