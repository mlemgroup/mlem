//
//  PreviewModifier+SampleEnvironment.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import SwiftUI

private struct SampleEnvironmentPreviewModifier: PreviewModifier {
    // Kinda unfortunate typealias naming considering we have our own AppState...
    typealias AppState = Void
    
    static func makeSharedContext() async throws -> AppState {
        // no-op
    }
    
    func body(content: Content, context: AppState) -> some View {
        content
            .environment(Palette.main)
            .environment(NavigationLayer(root: .blockList, model: .main))
            .environment(Mlem.AppState.main)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var sampleEnvironment: PreviewTrait { if #available(iOS 18.0, *) {
        return .modifier(SampleEnvironmentPreviewModifier())
    } else {
        return .defaultLayout
    } }
}
