//
//  EnvironmentValues+FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-24.
//

import Foundation
import SwiftUI

private struct FeedTypeEnvironmentKey: EnvironmentKey {
    static let defaultValue: FeedType? = nil
}

extension EnvironmentValues {
    var feedType: FeedType? {
        get { self[FeedTypeEnvironmentKey.self] }
        set { self[FeedTypeEnvironmentKey.self] = newValue }
    }
}
