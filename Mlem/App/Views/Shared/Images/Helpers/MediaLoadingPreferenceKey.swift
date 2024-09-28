//
//  MediaLoadingPreferenceKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import SwiftUI

struct MediaLoadingPreferenceKey: PreferenceKey {
    typealias Value = MediaLoadingState?
    static var defaultValue: Value = nil

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
