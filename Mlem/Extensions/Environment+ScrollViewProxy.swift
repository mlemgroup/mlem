//
//  Environment+ScrollViewProxy.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-19.
//

import SwiftUI

private struct ScrollViewProxyEnvironmentKey: EnvironmentKey {
    static let defaultValue: ScrollViewProxy? = nil
}

extension EnvironmentValues {
    /// Each tab has a root scroll view proxy that child views can use to perform scrolling.
    var tabScrollViewProxy: ScrollViewProxy? {
        get { self[ScrollViewProxyEnvironmentKey.self] }
        set { self[ScrollViewProxyEnvironmentKey.self] = newValue }
    }
}
