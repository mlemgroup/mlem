//
//  MediaOverlayView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-11.
//

import SwiftUI

@Observable
class MediaState {
    private(set) var url: URL?
    
    func setUrl(_ url: URL?) {
        withAnimation {
            self.url = url
        }
    }
}

struct MediaOverlayView: View {
    @Environment(MediaState.self) var mediaState
    
    let url: URL
    
    var body: some View {
        ImageViewer(url: url)
    }
}
