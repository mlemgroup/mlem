//
//  LemmyPrivateMessageReportView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension LemmyPrivateMessageReportView {
    func toPrivateMessageView() -> LemmyPrivateMessageView {
        .init(
            privateMessage: privateMessage,
            creator: privateMessageCreator,
            recipient: creator // Only the recipient of the message can report it.
        )
    }
}
