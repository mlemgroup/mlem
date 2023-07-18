//
//  AnotherTabViewItemsPreferencesKey.swift
//
//  Created by Christian on 21.07.22.
//

import Foundation
import SwiftUI

struct AnotherTabViewItemsPreferencesKey: PreferenceKey {
    static var defaultValue: [AnotherTabItem] { [] }

	static func reduce(value: inout [AnotherTabItem], nextValue: () -> [AnotherTabItem]) {
		value += nextValue()
	}
}
