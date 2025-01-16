//
//  NewMediaView+Functions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import Foundation

extension NewMediaView {
    func tapActions() {
        if let onTapActions {
            onTapActions()
        }
        if enableImageViewer, let viewerUrl = fullSizeUrl ?? loader.url {
            navigation.showImageViewer(url: viewerUrl)
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
