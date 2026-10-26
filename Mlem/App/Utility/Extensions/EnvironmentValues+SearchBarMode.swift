//
//  EnvironmentValues+SearchBarMode.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-20.
//

import SwiftUI

extension EnvironmentValues {
    var searchBarMode: SearchBarMode {
        switch (horizontalSizeClass, UIDevice.current.userInterfaceIdiom) {
        case (.compact, _): .compact
        case (.regular, .phone): .compact
        case _: .regular
        }
    }
}

enum SearchBarMode {
    /// Search bar has no "close" button.
    /// Tapping outside the search bar closes the search bar.
    case regular

    /// Search bar has a "close" button.
    /// Tapping outside the search bar does nothing.
    case compact
}
