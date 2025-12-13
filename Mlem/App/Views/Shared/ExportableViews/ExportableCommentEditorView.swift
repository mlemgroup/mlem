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
    
    @State var commentLoader: ExportableCommentLoader
    
    init(comment: any Comment1Providing, commentTreeTracker: CommentTreeTracker?) {
        self.commentLoader = .init(comment: comment, tracker: commentTreeTracker)
    }
    
    @State var threadLength: Int = 1 {
        didSet {
            guard let allParents = commentLoader.data?.comments else {
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
        if let error = commentLoader.error {
            ErrorView(error)
        } else if let data = commentLoader.data {
            content(data: data)
        } else {
            ProgressView()
                .task {
                    await commentLoader.load()
                }
        }
    }
    
    // swiftlint:disable:next function_body_length
    func content(data: ExportableCommentData) -> some View {
        ScrollView {
            exportableComment(data: data)
                .padding(.bottom, 200)
        }
        .presentationBackground(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            ExportableViewControlOverlay { createImageFromView(exportableComment(data: data)) }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", icon: .general.configure) {
                    Section(threadLength > 1 ? "Comments" : "Comment") {
                        Toggle("Creator", icon: .lemmy.person, isOn: $showCreator)
                        Toggle("Stats", icon: .lemmy.votes, isOn: $showStats)
                    }
                    
                    if data.comments.count > 1 {
                        ControlGroup("Parent Comments") {
                            Button {
                                assert(threadLength > 1, "Cannot decrease thread length below 1")
                                threadLength -= 1
                            } label: {
                                Image(icon: .general.remove)
                            }
                            .disabled(threadLength == 1)
                            
                            Text(verbatim: "\(threadLength - 1)")
                            
                            Button {
                                assert(
                                    threadLength < min(8, data.comments.count),
                                    "Cannot increase thread length beyond \(min(8, data.comments.count))"
                                )
                                threadLength += 1
                            } label: {
                                Image(icon: .general.add)
                            }
                            .disabled(threadLength == min(8, data.comments.count))
                        }
                        .controlGroupStyle(.compactMenu)
                    }
                    
                    Section("Post") {
                        Toggle("Show Post", icon: .lemmy.post, isOn: $showPost)
                        
                        if showPost {
                            Toggle("Community", icon: .lemmy.community, isOn: $postShowCommunity)
                            Toggle("Creator", icon: .lemmy.person, isOn: $postShowCreator)
                            Toggle("Stats", icon: .lemmy.votes, isOn: $postShowStats)
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
    func exportableComment(data: ExportableCommentData) -> some View {
        ExportableCommentView(
            comments: data.thread(length: threadLength),
            post: data.post,
            appState: appState,
            colorScheme: overriddenColorScheme
        )
        .allowsHitTesting(false)
    }
}
