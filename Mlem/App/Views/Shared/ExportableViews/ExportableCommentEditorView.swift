//
//  ExportableCommentEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-11-26.
//

import SwiftUI
import MlemMiddleware

struct ExportableCommentEditorView: View {
    @Environment(AppState.self) var appState
    
    let comment: any Comment1Providing
    @State var showCreator: Bool = true
    @State var showStats: Bool = true
    
    @State var snapshot: UIImage?
    
    var snapshotRenderHashValue: Int {
        var hasher = Hasher()
        hasher.combine(showCreator)
        hasher.combine(showStats)
        // hasher.combine(overriddenColorScheme)
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
    }
    
    var exportableComment: some View {
        ExportableCommentView(
            comment: comment,
            appState: appState,
            showCreator: true,
            showStats: true
        )
        .allowsHitTesting(false)
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
    
    private func createTempFile(data: Data, fileName: String) -> URL? {
        do {
            return try data.writeToTempFile(fileName: fileName)
        } catch {
            handleError(error)
            return nil
        }
    }
}
