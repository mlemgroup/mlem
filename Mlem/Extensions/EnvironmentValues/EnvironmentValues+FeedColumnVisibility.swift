//
//  EnvironmentValues+FeedColumnVisibility.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Foundation
import SwiftUI

private struct FeedColumnVisibility: EnvironmentKey {
    static let defaultValue: NavigationSplitViewVisibility = .automatic
}

extension EnvironmentValues {
    var feedColumnVisibility: NavigationSplitViewVisibility {
        get { self[FeedColumnVisibility.self] }
        set { self[FeedColumnVisibility.self] = newValue }
    }
}
