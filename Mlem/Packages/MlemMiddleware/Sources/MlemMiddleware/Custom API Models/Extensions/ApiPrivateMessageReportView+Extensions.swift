//
//  ApiPrivateMessageReportView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiPrivateMessageReportView {
    func toPrivateMessageView() -> ApiPrivateMessageView {
        .init(
            privateMessage: privateMessage,
            creator: privateMessageCreator,
            recipient: creator // Only the recipient of the message can report it.
        )
    }
}
