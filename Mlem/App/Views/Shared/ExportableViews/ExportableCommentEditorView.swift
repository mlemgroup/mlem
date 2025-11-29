//
//  ExportableCommentEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import SwiftUI
import MlemMiddleware

struct ExportableCommentEditorView: View {
    @Environment(AppState.self) var appState
    
    let comment: any Comment1Providing
    @State var showCreator: Bool = true
    @State var showStats: Bool = true
    
    @State var snapshot: UIImage?
    
    var snapshotRenderHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCreator)
        hasher.combine(showStats)
        // hasher.combine(overriddenColorScheme)
        return hasher.finalize()
    }
    
    var body: some View {
        ScrollView {
            exportableComment
                .padding(.bottom, 200)
        }
        .task(id: snapshotRenderHashValue) {
            snapshot = createImageFromView(exportableComment)
        }
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay(snapshot: snapshot)
        }
    }
    
    var exportableComment: some View {
        ExportableCommentView(
            comment: comment,
            appState: appState,
            showCreator: true,
            showStats: true
        )
        .allowsHitTesting(false)
    }
}
