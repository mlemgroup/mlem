//
//  NamedColor.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import SwiftUI

public struct NamedColor: Sendable {
    public var label: LocalizedStringResource
    public var color: Color
    
    public init(label: LocalizedStringResource, color: Color) {
        self.label = label
        self.color = color
    }
}

public extension NamedColor {
    static let red: Self = .init(label: "Red", color: .red)
    static let orange: Self = .init(label: "Orange", color: .orange)
    static let yellow: Self = .init(label: "Yellow", color: .yellow)
    static let green: Self = .init(label: "Green", color: .green)
    static let mint: Self = .init(label: "Mint", color: .mint)
    static let teal: Self = .init(label: "Teal", color: .teal)
    static let cyan: Self = .init(label: "Cyan", color: .cyan)
    static let blue: Self = .init(label: "Blue", color: .blue)
    static let indigo: Self = .init(label: "Indigo", color: .indigo)
    static let purple: Self = .init(label: "Purple", color: .purple)
    static let pink: Self = .init(label: "Pink", color: .pink)
    static let brown: Self = .init(label: "Brown", color: .brown)
    static let gray: Self = .init(label: "Gray", color: .gray)
}
