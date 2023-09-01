//
//  ScribSlider.swift
//  Mlem
//
//  Created by tht7 on 29/08/2023.
//

import SwiftUI

struct ScrubberSlider: View {
    @ObservedObject var mediaState: MediaState
    
    @State var getPlaybackPrecent: Double = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let barWidth = (width / 100) * getPlaybackPrecent
//            ZStack {
                HStack(spacing: 0) {
                    Color.white
                        .frame(width: barWidth, height: 4)
                    Color.gray
                        .frame(width: width - barWidth, height: 4)
                }
//            }
        }
        .frame(maxHeight: 3)
        .onChange(of: mediaState.currentTime) { [mediaState] newVal in
            getPlaybackPrecent = (100 / (mediaState.duration )) * (newVal)
        }
    }
}

#if DEBUG
struct ScrubberSliderPreview: PreviewProvider {
    @StateObject static var mediaState = MediaState()
    
    static var previews: some View {
        ScrubberSlider(mediaState: MediaState())
    }
}
#endif
