//
//  CommentBarThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import SwiftUI

struct CommentBarThemeSettingsView: View {
    var body: some View {
        Form {
            CommentBarThemePickerView()
        }
        .navigationTitle("Bar Colors")
    }
}
