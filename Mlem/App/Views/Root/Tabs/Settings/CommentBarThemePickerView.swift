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
            get: { commentBarTheme },
            set: { commentBarTheme = $0 }
        )) {
            ForEach(CommentBarTheme.allCases) { value in
                HStack(spacing: 16) {
                    CommentBarThemeDotsView(colors: value.colors(in: palette))
                    Text(value.label(in: palette))
                }
            }
        }
        .labelsHidden()
        .pickerStyle(.inline)
    }
}

struct CommentBarThemeDotsView: View {
    let colors: [Color]
    
    var body: some View {
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
