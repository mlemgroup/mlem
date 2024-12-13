//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(Palette.self) var palette
    @Environment(MediaState.self) var mediaState
    
    let url: URL
    
    @State var isZoomed: Bool = false
    @State var dragDistance: CGFloat = 0
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        self.url = components.url!
    }
    
    var body: some View {
        ZoomableContainer(isZoomed: $isZoomed) {
            DynamicMediaView(url: url, playImmediately: true)
                .padding(Constants.main.standardSpacing)
                .offset(y: dragDistance)
        }
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView {
                    mediaState.setUrl(nil)
                }
            }
        }
        .background(Color.black.opacity(1.0 - (abs(dragDistance) / UIScreen.main.bounds.height)))
//        .gesture(DragGesture(minimumDistance: 0.0)
//            .onChanged { value in
//                if !isZoomed {
//                    dragDistance = value.translation.height
//                }
//            }
//            .onEnded { value in
//                if abs(value.translation.height) > 200 {
//                    dragDistance = (value.translation.height > 0 ? 1000 : -1000)
//                    mediaState.setUrl(nil)
//                } else {
//                    dragDistance = 0
//                }
//            }
//        )
    }
}
