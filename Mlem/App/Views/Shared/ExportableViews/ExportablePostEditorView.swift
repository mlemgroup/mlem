//
//  ExportablePostEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-10-10.
//

import SwiftUI
import MlemMiddleware
import Theming
import ComponentViews
import Nuke
import Media
import Haptics

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
        .onChange(of: snapshotRenderHashValue, initial: true) {
            snapshot = createImageFromView(exportablePost)
        }
        .background(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            Group {
                if #available(iOS 26, *) {
                    controls
                        .glassEffect(.regular.interactive(), in: .capsule)
                } else {
                    controls
                        .background(.regularMaterial, in: .capsule)
                }
            }
            .padding(.horizontal, 50)
            .padding(Constants.main.standardSpacing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", systemImage: "slider.horizontal.3") {
                    Toggle("Community", isOn: $showCommunity)
                    Toggle("Creator", isOn: $showCreator)
                    Toggle("Stats", isOn: $showStats)
                    
                    if palette.supportedModes == .unspecified {
                        Menu("Color Scheme") {
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
    var controls: some View {
        HStack {
            saveButton
            shareButton
        }
        .font(.title2)
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .padding(.horizontal, Constants.main.halfSpacing)
    }
    
    @ViewBuilder var saveButton: some View {
        if let imageData = snapshot?.pngData() {
            Button("Save", icon: .general.import) {
                Task {
                    do {
                        try await ImageSaver().writeImageToPhotoAlbum(imageData: imageData)
                        ToastModel.main.add(.success("Image Saved"))
                    } catch {
                        handleError(error)
                    }
                }
            }
            .padding(Constants.main.standardSpacing)
            .contentShape(.rect)
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if let imageData = snapshot?.pngData(),
        let fileUrl = createTempFile(data: imageData, fileName: "post.png") {
            ShareLink(item: fileUrl)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        } else {
            ProgressView()
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
    
    private func createTempFile(data: Data, fileName: String) -> URL? {
        do {
            return try data.writeToTempFile(fileName: fileName)
        } catch {
            handleError(error)
            return nil
        }
    }
}
