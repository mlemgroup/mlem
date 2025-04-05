//
//  Empty Button Style.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Foundation
import SwiftUI

/// Style to disable navigation highlighting
public struct EmptyButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

public extension ButtonStyle where Self == EmptyButtonStyle {
    @MainActor static var empty: EmptyButtonStyle { .init() }
}
