//
//  PostEditorView+ImageView.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import PhotosUI
import SwiftUI

extension PostEditorView {
    @ViewBuilder
    var imageView: some View {
        switch imageManager?.state {
        case let .done(image):
            uploadedImageView(url: image.url) {
                Task {
                    do {
                        try await image.delete()
                    } catch {
                        handleError(error)
                    }
                }
            }
        case let .uploading(progress: progress):
            VStack {
                Text("Uploading...")
                    .foregroundStyle(palette.accent)
                if progress == 1.0 {
                    ProgressView()
                } else {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .frame(maxWidth: .infinity)
                        .padding([.bottom, .horizontal], 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: 16))
        case .idle:
            imageWaitingView
        case nil:
            if let imageUrl {
                uploadedImageView(url: imageUrl)
            }
        }
    }
    
    @ViewBuilder
    private func uploadedImageView(url: URL, onRemove: @escaping () -> Void = {}) -> some View {
        DynamicMediaView(url: url, actionsEnabled: false)
            .overlay(alignment: .topTrailing) {
                Button("Remove", systemImage: Icons.closeCircleFill) {
                    onRemove()
                    self.imageManager = nil
                    self.imageUrl = nil
                }
                .symbolRenderingMode(.palette)
                .foregroundStyle(.secondary, .thinMaterial)
                .font(.title)
                .labelStyle(.iconOnly)
                .padding()
            }
            .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var imageWaitingView: some View {
        VStack {
            HStack {
                Text("Upload an image...")
                    .fontWeight(.semibold)
                    .padding(.leading, 4)
                Spacer()
                Button("Remove", systemImage: Icons.closeCircleFill) {
                    imageManager = nil
                }
                .font(.title2)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(palette.accent)
                .fontWeight(.semibold)
                .font(.title2)
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(palette.accent)
            HVStack {
                Button("Photos", systemImage: "photo.on.rectangle.angled") {
                    guard let imageManager else { return }
                    navigation.showPhotosPicker(for: imageManager, api: primaryApi)
                }
                Button("Files", systemImage: "folder") {
                    guard let imageManager else { return }
                    navigation.showFilePicker(for: imageManager, api: primaryApi)
                }
                Button("Paste", systemImage: Icons.paste) {
                    guard let imageManager else { return }
                    navigation.uploadImageFromClipboard(for: imageManager, api: primaryApi)
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .buttonStyle(ImageSourceButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: 16))
    }
}

private struct ImageSourceButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(palette.selectedInteractionBarItem)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
            .background(palette.accent, in: .capsule)
    }
}

private struct HVStack<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ViewThatFits {
            HStack { content }
            VStack { content }
        }
    }
}
