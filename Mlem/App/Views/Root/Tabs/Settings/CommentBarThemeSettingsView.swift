//
//  CommentBarThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import SwiftUI

struct CommentBarThemeSettingsView: View {
    @Setting(\.appearance_showCommentBars) var showCommentBars

    var body: some View {
        Form {
            Section {
                Toggle("Show Bars", isOn: $showCommentBars)
            }
            if showCommentBars {
                CommentBarThemePickerView()
            }
        }
        .navigationTitle("Bars")
    }
}
