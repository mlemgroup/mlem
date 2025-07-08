//
//  Community3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public protocol Community3Providing: Community2Providing {
    var community3: Community3 { get }
    
    var instance: Instance1? { get }
    var moderators: [Person1] { get }
    var discussionLanguageIds: Set<Int> { get }
}

public extension Community3Providing {
    var community2: Community2 { community3.community2 }
    
    /// This is optional because it's defined as such on ``LemmyGetCommunityResponse``. I'm not sure when it actually returns `nil`.
    var instance: Instance1? { community3.instance }
    var moderators: [Person1] { community3.moderators }
    var discussionLanguageIds: Set<Int> { community3.discussionLanguageIds }
    
    var instance_: Instance1? { community3.instance }
    var moderators_: [Person1]? { community3.moderators }
    var discussionLanguageIds_: Set<Int>? { community3.discussionLanguageIds }
}

public extension Community3Providing {
    func upgrade() async throws -> any Community { self }
}
