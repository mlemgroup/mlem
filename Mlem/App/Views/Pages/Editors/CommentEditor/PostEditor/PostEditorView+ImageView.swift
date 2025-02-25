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
                    .foregroundStyle(.themedAccent)
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
            .background(.themedAccent.opacity(0.2), in: .rect(cornerRadius: 16))
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
        MediaView(
            url: url,
            aspectRatioBounds: .bounded(vertical: .init(width: 4, height: 5), horizontal: nil),
            cornerRadius: Constants.main.mediumItemCornerRadius)
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
                .foregroundStyle(.themedAccent)
                .fontWeight(.semibold)
                .font(.title2)
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(.themedAccent)
            HVStack {
                Button("Photos", systemImage: "photo.on.rectangle.angled") {
                    guard let imageManager else { return }
                    navigation.showPhotosPicker(for: imageManager, api: primaryApi)
                }
                Button("Files", systemImage: Icons.chooseFile) {
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
        .background(.themedAccent.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
    }
}

private struct ImageSourceButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(.themedContrastingLabel)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
            .background(.themedAccent, in: .capsule)
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
