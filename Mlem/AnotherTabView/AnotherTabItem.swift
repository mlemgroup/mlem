//
//  AnotherTabItem.swift
//
//  Created by Christian on 21.07.22.
//

import SwiftUI

enum AnotherTabItem: String, Hashable, Equatable, CaseIterable {
	case feed
	case inbox
	case profile
	case search
	case settings

    var title: String {
        rawValue.capitalized
    }
}
