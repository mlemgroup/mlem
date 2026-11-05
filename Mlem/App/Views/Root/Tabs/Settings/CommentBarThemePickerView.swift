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
        Section("Comment Bar Colors") {
            Picker("Comment Bar Colors", selection: $commentBarTheme) {
                ForEach(CommentBarTheme.allCases(in: palette)) { value in
                    Text(value.label)
                }
            }
        }
    }
}
