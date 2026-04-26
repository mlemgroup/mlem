//
//  ChevronButtonStyle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import Foundation
import SwiftUI

public struct ChevronButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        FormChevron {
            configuration.label
        }
    }
}

public extension ButtonStyle where Self == ChevronButtonStyle {
    @MainActor static var chevron: ChevronButtonStyle { .init() }
}
