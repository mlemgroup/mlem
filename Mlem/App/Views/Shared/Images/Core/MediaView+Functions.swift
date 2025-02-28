//
//  MediaView+Functions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import Foundation

extension MediaView {
    func tapActions() {
        if let onTapActions {
            onTapActions()
        }
        if enableImageViewer, let viewerUrl = fullSizeUrl ?? loader.url {
            navigation.showImageViewer(url: viewerUrl)
        }
    }
}
