//
//  ExportableCommentEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import SwiftUI
import MlemMiddleware

struct ExportableCommentEditorView: View {
    let comment: any Comment1Providing
    
    var body: some View {
        ExportableCommentView(comment: comment, showCreator: true, showStats: true)
    }
}
