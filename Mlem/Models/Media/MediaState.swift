//
//  MediaState.swift
//  Mlem
//
//  Created by tht7 on 25/08/2023.
//

import Foundation
import SwiftUI
import Nuke
import AVKit

class MediaState: ObservableObject {
    // what is our state
    @Published var isReady: Bool = false

    // what kind of file is it?
    @Published var isAnimated: Bool = false
    @Published var type: AssetType = .jpeg

    // does this media support a sound chanal?
    @Published var hasSound: Bool = false
    // should the media player mute that sound channel? (true by default)
    @Published var mute: Bool = true

    // controlls wheather the media is playing, true by default (and will loop the media)
    @Published var isPlaying: Bool = true

    // how long is the media
    @Published var duration: Double = .init()

    // for all those progressbars, that's how far along we are
    @Published var currentTime: Double = .init()

    @Published var isEditingCurrentTime: Bool = false

    // for advanced stuff Imma leave it here as well
    @Published var player: AVPlayer?
}
