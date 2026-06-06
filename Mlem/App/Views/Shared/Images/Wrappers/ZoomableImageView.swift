//
//  ZoomableImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

import SwiftUI
import Media

struct ZoomableImageView: View {
    let url: URL
    @Binding var controlState: MediaControlState
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let customDragMoved: ((BridgeDragValue) -> Void)?
    let customDragEnded: (() -> Void)?
    let customTap: (() -> Void)?
    
    var body: some View {
        MediaView(url: url, controlState: $controlState, overlays: .init([.error]))
            .overlay {
                ZoomRecognizer(
                    scale: $scale,
                    offset: $offset,
                    customDragMoved: customDragMoved,
                    customDragEnded: customDragEnded,
                    customTap: customTap
                )
            }
            .scaleEffect(scale)
            .offset(x: offset.width, y: offset.height)
    }
}
