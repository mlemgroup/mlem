//
//  PostEditorView+ImageView.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import MlemMiddleware
import PhotosUI
import SwiftUI

extension PostEditorView {
    var imageView: some View {
        PostEditorImageUploadWidgetView(primaryApi: primaryApi, imageUrl: $imageUrl, imageManager: $imageManager)
    }
}

struct PostEditorImageUploadWidgetView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(MediaTracker.self) var mediaTracker
    
    @ScaledMetric(relativeTo: .subheadline) var buttonHeight: CGFloat = 40
    
    let primaryApi: ApiClient
    @Binding var imageUrl: URL?
    @Binding var imageManager: ImageUploadManager?
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            switch imageManager?.state {
            case let .done(image):
                uploadedImageView(url: image.url) {
                    Task {
                        do {
                            try await image.delete()
                        } catch {
                            handleError(error, silent: true)
                        }
                    }
                }
                .transition(.opacity)
            case let .uploading(progress: progress):
                uploadingProgressView(progress: progress)
                    .transition(.opacity)
            default:
                if let imageUrl, imageManager?.state != .idle {
                    uploadedImageView(url: imageUrl)
                } else {
                    imageWaitingView
                }
            }
        }
        .background(.themedAccent.opacity(imageUrl != nil || imageManager?.image != nil ? 0 : 0.2))
        // This second background is to prevent the view from being partially see-through, which makes the animations cleaner
        .background(.themedGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .onTapGesture {
            imageManager = imageManager ?? .init()
        }
    }
    
    @ViewBuilder
    private func uploadedImageView(url: URL, onRemove: @escaping () -> Void = {}) -> some View {
        MediaView(
            controlState: .constant(mediaTracker.controlState(for: url) {
                .init(url: url, blurred: false, animating: false, muted: false)
            }),
            aspectRatioBounds: .imageDefault,
            cornerRadius: Constants.main.mediumItemCornerRadius
        )
        .overlay(alignment: .topTrailing) {
            Button("Remove", systemImage: Icons.closeCircleFill) {
                onRemove()
                imageManager = nil
                imageUrl = nil
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
        VStack(spacing: 8) {
            HStack {
                HStack {
                    if imageManager?.state == nil {
                        Image(icon: .markdown.uploadImage)
                    }
                    Text(imageManager?.state == nil ? "Add Image" : "Add an image...")
                }
                .geometryGroup()
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: imageManager?.state == nil ? .center : .leading)
                if imageManager?.state != nil {
                    Button("Remove", systemImage: Icons.closeCircleFill) {
                        imageManager = nil
                    }
                    .font(.title2)
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.themedAccent)
                }
            }
            .foregroundStyle(.themedAccent)
            if imageManager?.state != nil {
                VStack {
                    uploadOptionsView(height: buttonHeight + 14)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    
    @ViewBuilder
    func uploadingProgressView(progress: Double) -> some View {
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
    }
    
    @ViewBuilder
    func uploadOptionsView(height: CGFloat) -> some View {
        HStack {
            Button("Photos", icon: .general.photoLibary) {
                guard let imageManager else { return }
                navigation.showPhotosPicker(for: imageManager, api: primaryApi)
            }
            Button("Files", icon: .general.chooseFile) {
                guard let imageManager else { return }
                navigation.showFilePicker(for: imageManager, api: primaryApi)
            }
            Button("Paste", icon: .general.paste) {
                guard let imageManager else { return }
                navigation.uploadImageFromClipboard(for: imageManager, api: primaryApi)
            }
        }
        .font(.subheadline)
        .buttonStyle(ImageSourceButtonStyle(height: height))
    }
}

private struct ImageSourceButtonStyle: ButtonStyle {
    let height: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .labelStyle(ImageSourceButtonLabelStyle())
            .foregroundStyle(.themedContrastingLabel)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(.themedAccent, in: .rect(cornerRadius: 8))
    }
}

private struct ImageSourceButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
    }
}
