//
//  ImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import Nuke
import SwiftUI

private extension UIImage {
    static let blank: UIImage = .init()
}

struct ImageView: View {
    @Environment(Palette.self) var palette: Palette
    
    enum LoadingState {
        case waiting, loading, done, failed
    }
    
    @State var uiImage: UIImage?
    @State var loading: LoadingState
    @State var aspectRatio: CGSize
    @State var error: Error?
    
    let url: URL?
    let onLoadingStateChange: (_ newValue: LoadingState) -> Void
    
    init(url: URL?, onLoadingStateChange: @escaping (_ newValue: LoadingState) -> Void = { _ in }) {
        self.url = url
        self.onLoadingStateChange = onLoadingStateChange
        if let image = ImagePipeline.shared.cache.cachedImage(for: .init(url: url))?.image {
            self._uiImage = .init(wrappedValue: image)
            self._aspectRatio = .init(wrappedValue: image.size)
            self._loading = .init(initialValue: .done)
        } else {
            self._uiImage = .init(wrappedValue: nil)
            self._aspectRatio = .init(wrappedValue: .init(width: 4, height: 3))
            self._loading = .init(initialValue: url == nil ? .done : .waiting)
        }
    }
    
    var body: some View {
        Image(uiImage: uiImage ?? .blank)
            .resizable()
            .aspectRatio(aspectRatio, contentMode: .fit)
            .background {
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
            .task(loadImage)
            .clipShape(.rect(cornerRadius: AppConstants.largeItemCornerRadius))
            .onAppear {
                onLoadingStateChange(loading)
            }
            .onChange(of: loading) {
                onLoadingStateChange(loading)
            }
    }
    
    @Sendable
    @MainActor
    func loadImage() async {
        guard let url, uiImage == nil, loading == .waiting else { return }
        do {
            loading = .loading
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            let image = try await imageTask.image
            uiImage = image
            loading = .done
            aspectRatio = image.size
        } catch {
            self.error = error
            loading = .failed
        }
    }
}
