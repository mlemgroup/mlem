//
//  Environment+ScrollViewReaderProxy.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-12.
//

import SwiftUI

private struct ScrollViewReaderProxy: EnvironmentKey {
    static let defaultValue: ScrollViewProxy? = nil
}

extension EnvironmentValues {
    var scrollViewProxy: ScrollViewProxy? {
        get { self[ScrollViewReaderProxy.self] }
        set { self[ScrollViewReaderProxy.self] = newValue }
    }
}
