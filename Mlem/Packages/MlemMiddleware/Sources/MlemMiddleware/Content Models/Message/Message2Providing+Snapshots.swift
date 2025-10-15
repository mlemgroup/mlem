//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-12.
//

import Foundation

extension Message2Providing {
    func takeSnapshot2() -> Message2Snapshot {
        .init(
            message: message1.takeSnapshot1(),
            creator: creator.takeSnapshot1(),
            recipient: recipient.takeSnapshot1()
        )
    }
}
