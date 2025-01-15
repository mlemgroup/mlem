//
//  NewMediaView+Modifiers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

private struct MediaContextMenu: ViewModifier {
    @State var quickLookUrl: URL?
    
    let url: URL
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("Save Image", systemImage: Icons.import) {
                    Task { await saveImage(url: url) }
                }
//                Button("Share Image", systemImage: Icons.share) {
//                    Task { await shareImage(url: url) }
//                }
//                Button("Quick Look", systemImage: Icons.imageDetails) {
//                    Task { await showQuickLook(url: url) }
//                }
            }
            .quickLookPreview($quickLookUrl)
    }
}

extension NewMediaView {
    func withContextMenu() -> some View {
        modifier(MediaContextMenu(url: loader.url))
    }
}
