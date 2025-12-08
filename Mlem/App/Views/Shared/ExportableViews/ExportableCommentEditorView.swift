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
import os

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
    
    let commentTreeTracker: CommentTreeTracker?
    @State var allParents: [any Comment2Providing]?
    
    @State var threadLength: Int = 1 {
        didSet {
            guard let allParents else {
                assertionFailure("Cannot modify thread length without thread")
                return
            }
            comments = allParents.suffix(threadLength)
        }
    }
    @State var comments: [any Comment2Providing] = .init()
    
    var overriddenColorScheme: ColorScheme {
        switch overrideColorScheme {
        case .unspecified: colorScheme
        case .light: .light
        case .dark: .dark
        default: .light
        }
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
                        comment = comment2
        
                        if let commentTreeTracker {
                            Logger.dev.info("Tracker present")
                            await commentTreeTracker.load(ensuringPresenceOf: comment2)
                            self.allParents = commentTreeTracker.getThread(preceding: comment2, limit: 8)
                            Logger.dev.info("Found thread \(allParents?.count ?? -1) long")
                        }
                        
                        guard let post3 = try await comment2.post.upgrade() as? any Post3Providing else {
                            assertionFailure("Could not cast to Post2Providing post-upgrade")
                            throw ApiClientError.unsuccessful
                        }
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
        .presentationBackground(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay { createImageFromView(exportableComment) }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", icon: .general.configure) {
                    Section("Comment") { // TODO: NOW "Comments" if multiple
                        Toggle("Creator", icon: .lemmy.person, isOn: $showCreator)
                        Toggle("Stats", icon: .lemmy.votes, isOn: $showStats)
                    }
                    
                    if commentTreeTracker != nil {
                        ControlGroup("Parent Comments") {
                            Button {
                                threadLength -= 1
                            } label: {
                                Image(icon: .general.remove)
                            }
                            Button {
                                threadLength += 1
                            } label: {
                                Image(icon: .general.add)
                            }
                        }
                        .controlGroupStyle(.compactMenu)
                    }
                    
                    if comment is any Comment2Providing {
                        Section("Post") {
                            Toggle("Show Post", icon: .lemmy.post, isOn: $showPost)
                            
                            if showPost {
                                Toggle("Community", icon: .lemmy.community, isOn: $postShowCommunity)
                                Toggle("Creator", icon: .lemmy.person, isOn: $postShowCreator)
                                Toggle("Stats", icon: .lemmy.votes, isOn: $postShowStats)
                            }
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
                comments: comments,
                post: post,
                appState: appState,
                colorScheme: overriddenColorScheme
            )
            .allowsHitTesting(false)
        }
    }
}
