//
//  ImageLoadingPreferenceKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import SwiftUI

struct ImageLoadingPreferenceKey: PreferenceKey {
    typealias Value = ImageLoadingState
    static var defaultValue: Value = .loading

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
