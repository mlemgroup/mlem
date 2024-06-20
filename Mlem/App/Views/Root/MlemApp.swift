//
//  MlemApp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Nuke
import SwiftUI

/// Root view for the app
@main
struct MlemApp: App {
    var body: some Scene {
        WindowGroup {
            FlowRoot()
                .onAppear(perform: startupActions)
        }
    }
    
    func startupActions() {
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
    }
}
