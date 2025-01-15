//
//  NewMediaView+Modifiers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

private struct MediaContextMenu: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    
    @State var quickLookUrl: URL?
    
    let url: URL?
    
    func body(content: Content) -> some View {
        if let url {
            content
                .contextMenu {
                    Button("Save Image", systemImage: Icons.import) {
                        Task { await saveImage(url: url) }
                    }
                    Button("Share Image", systemImage: Icons.share) {
                        Task { await shareImage(url: url) }
                    }
                    Button("Quick Look", systemImage: Icons.imageDetails) {
                        Task { await showQuickLook(url: url) }
                    }
                }
                .quickLookPreview($quickLookUrl)
        } else {
            content
        }
    }
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            navigation.shareInfo = .init(url: fileUrl)
        }
    }
    
    func showQuickLook(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            quickLookUrl = fileUrl
        }
    }
}

extension NewMediaView {
    func withContextMenu() -> some View {
        return modifier(MediaContextMenu(url: fullSizeUrl(url: loader.url)))
    }
}
