//
//  View+TabBarPreview.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation
import SwiftUI

#if DEBUG
    struct TabBarPreviewModifier: ViewModifier {
        @Environment(AppState.self) var appState
    
        var selected: ContentView.Tab
    
        func body(content: Content) -> some View {
            TabView(selection: .constant(selected)) {
                ForEach(ContentView.Tab.allCases, id: \.self) { type in
                    content
                        .tag(type)
                        .tabItem {
                            Label(
                                type.label(appState: appState, profileLabelType: .anonymous),
                                systemImage: selected == type ? type.systemImageFill : type.systemImage
                            )
                        }
                }
            }
        }
    }

    extension View {
        func previewTabBar(selected: ContentView.Tab) -> some View {
            modifier(TabBarPreviewModifier(selected: selected))
        }
    }
#endif
