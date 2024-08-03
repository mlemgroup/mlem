//
//  FixedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-31.
//

import Foundation
import MlemMiddleware
import Nuke
import SwiftUI

/// Image view that always has a 1:1 aspect ratio. Inherits sizing from parent frame.
struct FixedImageView: View {
    @Environment(Palette.self) var palette
    
    @State private var uiImage: UIImage
    @State private var loading: ImageLoadingState
    
    let url: URL?
    let fallback: Fallback
    let showProgress: Bool
    
    /// Enumeration of placeholder images to use if image loading fails
    enum Fallback {
        case person, community, instance, favicon, image
        
        var icon: String {
            switch self {
            case .person: Icons.userFill
            case .community: Icons.communityFill
            case .instance: Icons.instanceFill
            case .favicon: Icons.browser
            case .image: Icons.missing
            }
        }
    }
    
    init(
        url: URL?,
        fallback: Fallback,
        showProgress: Bool
    ) {
        self.url = url
        self.fallback = fallback
        self.showProgress = showProgress
    
        self._uiImage = .init(wrappedValue: .init())
        self._loading = .init(wrappedValue: url == nil ? .failed : .loading)
    }
    
    var body: some View {
        Color.clear.contentShape(.rect)
            .overlay {
                content
                    .task(loadImage)
                    .aspectRatio(1, contentMode: .fill)
                    .preference(key: ImageLoadingPreferenceKey.self, value: loading)
                    .allowsHitTesting(false)
            }
    }
    
    @ViewBuilder
    var content: some View {
        if loading == .failed || (loading == .loading && !showProgress) {
            fallbackImage
        } else {
            if loading == .loading {
                ProgressView().tint(.secondary)
            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
    
    @ViewBuilder
    var fallbackImage: some View {
        switch fallback {
        case .person, .community, .instance:
            Image(systemName: fallback.icon)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .gray.gradient)
        case .favicon:
            Image(systemName: fallback.icon)
                .foregroundStyle(palette.secondary)
        case .image:
            Image(systemName: fallback.icon)
                .font(.title)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
        }
    }
    
    @Sendable
    func loadImage() async {
        guard let url else { return }
        
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            uiImage = try await imageTask.image
            loading = .done
        } catch {
            loading = .failed
            print(error)
        }
    }
}
