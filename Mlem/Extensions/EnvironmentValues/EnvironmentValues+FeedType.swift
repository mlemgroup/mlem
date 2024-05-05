//
//  EnvironmentValues+FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-24.
//

import Foundation
import SwiftUI

private struct FeedTypeEnvironmentKey: EnvironmentKey {
    static let defaultValue: PostFeedType? = nil
}

extension EnvironmentValues {
    var feedType: PostFeedType? {
        get { self[FeedTypeEnvironmentKey.self] }
        set { self[FeedTypeEnvironmentKey.self] = newValue }
    }
}
