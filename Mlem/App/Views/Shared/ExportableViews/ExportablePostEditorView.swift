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
    
    let post: any Post1Providing
    @State var showCommunity: Bool = true
    @State var showCreator: Bool = true
    @State var showStats: Bool = true
    @State var overrideColorScheme: UIUserInterfaceStyle = .unspecified
    
    var overriddenColorScheme: ColorScheme {
        switch overrideColorScheme {
        case .unspecified: colorScheme
        case .light: .light
        case .dark: .dark
        default: .light
        }
    }
    
    @State var snapshot: UIImage?
    
    var snapshotRenderHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCommunity)
        hasher.combine(showCreator)
        hasher.combine(showStats)
        hasher.combine(overriddenColorScheme)
        return hasher.finalize()
    }

    var body: some View {
        ScrollView {
            exportablePost
                .padding(.bottom, 200)
        }
        .task(id: snapshotRenderHashValue) {
            snapshot = createImageFromView(exportablePost)
        }
        .presentationBackground(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay(snapshot: snapshot)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", systemImage: "slider.horizontal.3") {
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
            colorScheme: overriddenColorScheme,
            showCommunity: showCommunity,
            showCreator: showCreator,
            showStats: showStats
        )
        .allowsHitTesting(false)
    }
}
