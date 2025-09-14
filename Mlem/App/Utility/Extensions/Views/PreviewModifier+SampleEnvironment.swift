//
//  PreviewModifier+SampleEnvironment.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Haptics
import MlemMiddleware
import SwiftUI

#if DEBUG
    private struct SampleEnvironmentPreviewModifier: PreviewModifier {
        // Kinda unfortunate typealias naming considering we have our own AppState...
        typealias AppState = Void
    
        var api: MockApiClient = .mock
    
        static func makeSharedContext() async throws -> AppState {
            // no-op
        }
    
        func body(content: Content, context: AppState) -> some View {
            content
                .environment(NavigationLayer(root: .blockList, model: .main))
                .environment(Mlem.AppState.mock(api: api))
                .environment(FiltersTracker.main)
                .environment(TabReselectTracker.main)
                .environment(BackendClient.main)
                .environment(HapticManager.main)
        }
    }

    extension PreviewTrait where T == Preview.ViewTraits {
        static var sampleEnvironment: PreviewTrait {
            if #available(iOS 18.0, *) {
                return .modifier(SampleEnvironmentPreviewModifier())
            } else {
                return .defaultLayout
            }
        }
    
        static func sampleEnvironment(api: MockApiClient) -> PreviewTrait {
            if #available(iOS 18.0, *) {
                return .modifier(SampleEnvironmentPreviewModifier(api: api))
            } else {
                return .defaultLayout
            }
        }
    }
#endif
