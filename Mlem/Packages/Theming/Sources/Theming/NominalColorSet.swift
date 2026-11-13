//
//  NominalColorSet.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-13.
//

import SwiftUI

public struct NominalColorSet {
    public let orange: Color
    public let pink: Color
    public let blue: Color
    public let green: Color
    public let purple: Color
    public let indigo: Color
    public let mint: Color
    public let teal: Color
    public let yellow: Color
    public let cyan: Color
    public let red: Color
    
    public init(
        orange: Color,
        pink: Color,
        blue: Color,
        green: Color,
        purple: Color,
        indigo: Color,
        mint: Color,
        teal: Color,
        yellow: Color,
        cyan: Color,
        red: Color
    ) {
        self.orange = orange
        self.pink = pink
        self.blue = blue
        self.green = green
        self.purple = purple
        self.indigo = indigo
        self.mint = mint
        self.teal = teal
        self.yellow = yellow
        self.cyan = cyan
        self.red = red
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    public func get(_ type: NominalColor) -> Color {
        switch type {
        case .orange: orange
        case .pink: pink
        case .blue: blue
        case .green: green
        case .purple: purple
        case .indigo: indigo
        case .mint: mint
        case .teal: teal
        case .yellow: yellow
        case .cyan: cyan
        case .red: red
        }
    }
}
