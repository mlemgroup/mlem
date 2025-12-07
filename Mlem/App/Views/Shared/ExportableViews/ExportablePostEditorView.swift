//
//  ExportablePostEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-10-10.
//

import ComponentViews
import Haptics
import Media
import MlemMiddleware
import Nuke
import SwiftUI
import Theming

struct ExportablePostEditorView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    
    @Environment(\.colorScheme) var colorScheme
    @Setting(\.appearance_palette) var palette
    @Setting(\.post_createImage_showCommunity) var showCommunity
    @Setting(\.post_createImage_showCreator) var showCreator
    @Setting(\.post_createImage_showStats) var showStats
    @Setting(\.post_createImage_colorScheme) var overrideColorScheme
    
    let post: any Post1Providing
    
    var overriddenColorScheme: ColorScheme {
        switch overrideColorScheme {
        case .unspecified: colorScheme
        case .light: .light
        case .dark: .dark
        default: .light
        }
    }

    var body: some View {
        ScrollView {
            exportablePost
                .padding(.bottom, 200)
        }
        .presentationBackground(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay { createImageFromView(exportablePost) }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", icon: .general.configure) {
                    Toggle("Community", icon: .lemmy.community, isOn: $showCommunity)
                    Toggle("Creator", icon: .lemmy.person, isOn: $showCreator)
                    Toggle("Stats", icon: .lemmy.votes, isOn: $showStats)
                    
                    if palette.supportedModes == .unspecified {
                        Menu("Color Scheme", icon: overrideColorScheme.icon) {
                            Picker("Color Scheme", selection: $overrideColorScheme) {
                                ForEach(UIUserInterfaceStyle.optionCases, id: \.self) { style in
                                    Label(style.label, icon: style.icon)
                                }
                            }
                        }
                    }
                }
                .menuActionDismissBehavior(.disabled)
            }
        }
    }
        
    var exportablePost: some View {
        ExportablePostView(
            post: post,
            appState: appState,
            colorScheme: overriddenColorScheme
        )
        .allowsHitTesting(false)
    }
}
