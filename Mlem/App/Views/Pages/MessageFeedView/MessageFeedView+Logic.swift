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
                feedLoader?.insertCreatedMessage(message)
                scrollProxy.scrollTo(message.id, anchor: .bottom)
            }
            textView.text = ""
        } catch {
            handleError(error)
        }
    }
}
