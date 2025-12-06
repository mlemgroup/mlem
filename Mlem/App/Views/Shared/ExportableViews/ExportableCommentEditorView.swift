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
    @Setting(\.comment_createImage_showPost) var showPost: Bool
    @Setting(\.comment_createImage_showCreator) var showCreator: Bool
    @Setting(\.comment_createImage_showStats) var showStats: Bool
    @Setting(\.comment_createImage_colorScheme) var overrideColorScheme: UIUserInterfaceStyle
    @Setting(\.post_createImage_showCommunity) var postShowCommunity
    @Setting(\.post_createImage_showCreator) var postShowCreator
    @Setting(\.post_createImage_showStats) var postShowStats
    
    @State var comment: any Comment1Providing
    @State var post: (any Post3Providing)?
    
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
        if comment is any Comment2Providing, post != nil {
            content
        } else {
            ProgressView()
                .task {
                    do {
                        guard let comment2 = try await comment.upgrade() as? any Comment2Providing else {
                            assertionFailure("Could not cast to Comment2Providing post-upgrade")
                            throw ApiClientError.unsuccessful
                        }
                        guard let post3 = try await comment2.post.upgrade() as? any Post3Providing else {
                            assertionFailure("Could not cast to Post2Providing post-upgrade")
                            throw ApiClientError.unsuccessful
                        }
                        comment = comment2
                        post = post3
                    } catch {
                        handleError(error)
                    }
                }
        }
    }
    
    var content: some View {
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
                Menu("Details", icon: .general.configure) {
                    Toggle("Creator", icon: .lemmy.person, isOn: $showCreator)
                    Toggle("Stats", icon: .lemmy.votes, isOn: $showStats)
                    
                    if comment is any Comment2Providing {
                        Toggle("Post", icon: .lemmy.post, isOn: $showPost)
                        if showPost {
                            Menu("Post Details", icon: .general.configure) {
                                Toggle("Community", icon: .lemmy.community, isOn: $postShowCommunity)
                                Toggle("Creator", icon: .lemmy.person, isOn: $postShowCreator)
                                Toggle("Stats", icon: .lemmy.votes, isOn: $postShowStats)
                            }
                            .menuActionDismissBehavior(.disabled) // this doesn't work but I think that's a bug
                        }
                    }
                    
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
    
    @ViewBuilder
    var exportableComment: some View {
        if let post {
            ExportableCommentView(
                comment: comment,
                post: post,
                appState: appState,
                colorScheme: overriddenColorScheme
            )
            .allowsHitTesting(false)
        }
    }
}
