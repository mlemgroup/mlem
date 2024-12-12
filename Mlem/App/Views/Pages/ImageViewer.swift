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
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        self.url = components.url!
    }
    
    var body: some View {
        ZoomableContainer {
            DynamicMediaView(url: url, playImmediately: true)
                .padding(Constants.main.standardSpacing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloseButtonView {
                    withAnimation {
                        mediaState.url = nil
                    }
                }
            }
        }
        .background(Color.black)
        // .background(palette.background)
    }
}
