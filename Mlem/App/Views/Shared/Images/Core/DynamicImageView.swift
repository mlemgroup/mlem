//
//  DynamicImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import Nuke
import SwiftUI

private extension UIImage {
    static let blank: UIImage = .init()
}

struct DynamicImageView: View {
    @Environment(Palette.self) var palette: Palette
    
    @State var uiImage: UIImage?
    @State var loading: ImageLoadingState
    @State var aspectRatio: CGSize
    @State var error: Error?
    
    let url: URL?
    let showError: Bool
    let cornerRadius: CGFloat
    
    init(
        url: URL?,
        showError: Bool = true,
        cornerRadius: CGFloat = AppConstants.largeItemCornerRadius
    ) {
        self.url = url
        self.showError = showError
        self.cornerRadius = cornerRadius
        if let image = ImagePipeline.shared.cache.cachedImage(for: .init(url: url))?.image {
            self._uiImage = .init(wrappedValue: image)
            self._aspectRatio = .init(wrappedValue: image.size)
            self._loading = .init(initialValue: .done)
        } else {
            self._uiImage = .init(wrappedValue: nil)
            self._aspectRatio = .init(wrappedValue: .init(width: 4, height: 3))
            self._loading = .init(initialValue: url == nil ? .failed : .loading)
        }
    }
    
    var body: some View {
        Image(uiImage: uiImage ?? .blank)
            .resizable()
            .aspectRatio(aspectRatio, contentMode: .fit)
            .background {
                if showError {
                    palette.secondaryBackground
                        .overlay {
                            if error != nil {
                                Image(systemName: Icons.missing)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50)
                                    .padding(4)
                                    .foregroundStyle(palette.tertiary)
                            }
                        }
                }
            }
            .task(loadImage)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .preference(key: ImageLoadingPreferenceKey.self, value: loading)
    }
    
    @Sendable
    @MainActor
    func loadImage() async {
        guard let url, uiImage == nil else { return }
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            let image = try await imageTask.image
            uiImage = image
            loading = .done
            aspectRatio = image.size
        } catch {
            print(error)
            self.error = error
            loading = .failed
        }
    }
}
