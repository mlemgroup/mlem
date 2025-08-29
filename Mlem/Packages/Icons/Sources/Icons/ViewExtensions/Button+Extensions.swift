//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-10.
//

import SwiftUI

public extension Button where Label == SwiftUI.Label<Text, Image> {
    nonisolated init(
        _ title: LocalizedStringResource,
        icon: Icon,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(LocalizedStringKey(title.key), systemImage: icon.computeImageName(), role: role, action: action)
    }
    
    @_disfavoredOverload
    nonisolated init(
        _ title: String,
        icon: Icon,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title, systemImage: icon.computeImageName(), role: role, action: action)
    }
}
