//
//  MessageFeedView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-23.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension MessageFeedView {
    func sendMessage(_ scrollProxy: ScrollViewProxy) async {
        do {
            guard let person = person.wrappedValue as? any Person, !textView.text.isEmpty else { return }
            let message = try await appState.firstApi.createMessage(personId: person.id, content: textView.text)
            withAnimation {
                feedLoader?.prependItem(message)
                scrollProxy.scrollTo(message.id, anchor: .bottom)
            }
            textView.text = ""
        } catch {
            handleError(error)
        }
    }
    
    func editMessage(_ message: any Message) async {
        do {
            try await message.edit(content: textView.text)
            editing = nil
            textView.text = ""
            textView.resignFirstResponder()
        } catch {
            handleError(error)
        }
    }
    
    func messageIsFirstOfDay(_ message: Message2) -> Bool {
        guard let feedLoader else { return false }
        guard let index = feedLoader.items.firstIndex(of: message) else {
            assertionFailure()
            return false
        }
        guard index < feedLoader.items.count - 1 else { return true }
        let previousMessage = feedLoader.items[index + 1]
        return !Calendar.current.isDate(previousMessage.created, inSameDayAs: message.created)
    }
    
    var minTextEditorHeight: CGFloat {
        Constants.main.standardSpacing * 2 + UIFont.preferredFont(forTextStyle: .body).lineHeight
    }
    
    func messageFooterText(for message: Message2) -> String? {
        var parts: [String] = .init()
        if message == feedLoader?.items.first, Calendar.current.isDateInToday(message.created) {
            parts.append(message.created.formatted(date: .omitted, time: .shortened))
        }
        if message.updated != nil {
            parts.append(.init(localized: "Edited"))
        }
        return parts.joined(separator: " • ")
    }
}
