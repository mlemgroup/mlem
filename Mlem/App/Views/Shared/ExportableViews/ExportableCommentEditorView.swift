//
//  ExportableCommentEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import ComponentViews
import SwiftUI
import MlemMiddleware
import Theming

struct ExportableCommentEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(\.colorScheme) var colorScheme
    @Setting(\.appearance_palette) var palette
    
    let comment: any Comment1Providing
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
    @State var snapshotRerender: Bool = false
    
    var snapshotRenderHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCreator)
        hasher.combine(showStats)
        hasher.combine(overriddenColorScheme)
        return hasher.finalize()
    }
    
    var body: some View {
        ScrollView {
            exportableComment
                .padding(.bottom, 200)
        }
        .task(id: snapshotRenderHashValue) {
            snapshot = createImageFromView(exportableComment)
        }
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay(snapshot: snapshot) { createImageFromView(exportableComment) }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", systemImage: "slider.horizontal.3") {
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
    
    var exportableComment: some View {
        ExportableCommentView(
            comment: comment,
            appState: appState,
            colorScheme: overriddenColorScheme,
            showCreator: showCreator,
            showStats: showStats
        )
        .allowsHitTesting(false)
    }
}
