//
//  CommentBarThemePickerView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import SwiftUI
import Theming

struct CommentBarThemePickerView: View {
    @Setting(\.appearance_commentBarTheme) var commentBarTheme
    @Environment(\.palette) var palette

    var body: some View {
        Picker("Comment Bar Colors", selection: .init(
            get: { commentBarTheme.clamped(for: palette) },
            set: { commentBarTheme = $0 }
        )) {
            ForEach(CommentBarTheme.allCases(in: palette)) { value in
                HStack(spacing: 16) {
                    dotsView(value.colors(in: palette))
                    Text(value.label(in: palette))
                }
            }
        }
        .labelsHidden()
        .pickerStyle(.inline)
    }

    @ViewBuilder
    func dotsView(_ colors: [Color]) -> some View {
        let repeatedColors = (0..<6).lazy.map { colors[$0 % colors.count] }
        HStack {
            ForEach(repeatedColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 8)
            }
        }
    }
}
