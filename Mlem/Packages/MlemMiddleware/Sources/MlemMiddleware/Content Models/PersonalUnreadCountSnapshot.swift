//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct PersonalUnreadCountSnapshot {
    let replies: Int
    let mentions: Int
    let messages: Int
    
    var total: Int {
        replies + mentions + messages
    }
}
