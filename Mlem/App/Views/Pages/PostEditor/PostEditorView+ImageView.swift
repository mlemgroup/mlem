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
    func imageView(imageManager: ImageUploadManager) -> some View {
        switch imageManager.state {
        case let .done(image):
            DynamicImageView(url: image.url, actionsEnabled: false)
                .overlay(alignment: .topTrailing) {
                    Button("Remove", systemImage: Icons.closeCircleFill) {
                        Task {
                            do {
                                try await image.delete()
                            } catch {
                                handleError(error)
                            }
                        }
                        self.imageManager = nil
                    }
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary, .thinMaterial)
                    .font(.title)
                    .labelStyle(.iconOnly)
                    .padding()
                }
                .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
                .frame(maxWidth: .infinity)
        case let .uploading(progress: progress):
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: 16))
        default:
            imageWaitingView
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
                .foregroundStyle(palette.accent)
                .fontWeight(.semibold)
                .font(.title2)
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(palette.accent)
            HVStack {
                Button("Photos", systemImage: "photo.on.rectangle.angled") {
                    imageUploadPresentationState = .photos
                }
                Button("Files", systemImage: "folder") {
                    imageUploadPresentationState = .files
                }
                Button("Paste", systemImage: Icons.paste) {
                    Task {
                        do {
                            try await imageManager?.pasteFromClipboard(api: primaryApi)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
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
