//
//  DynamicImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import Nuke
import SwiftUI

extension UIImage {
    static let blank: UIImage = .init()
}

struct DynamicImageView: View {
    @Environment(Palette.self) var palette: Palette
    
    @State var loader: ImageLoader
    
    @State var loadingPref: ImageLoadingState?
    
    let showError: Bool
    let cornerRadius: CGFloat
    
    init(
        url: URL?,
        maxSize: CGFloat? = nil,
        showError: Bool = true,
        cornerRadius: CGFloat = Constants.main.mediumItemCornerRadius
    ) {
        self.showError = showError
        self.cornerRadius = cornerRadius
        self._loader = .init(wrappedValue: .init(url: url, maxSize: maxSize))
    }
    
    var body: some View {
        Image(uiImage: loader.uiImage ?? .blank)
            .resizable()
            .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
            .background {
                if showError {
                    palette.secondaryBackground
                        .overlay {
                            if loader.error != nil {
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
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
            .preference(key: ImageLoadingPreferenceKey.self, value: loadingPref)
            .task(loader.load)
            .contextMenu {
                if let uiImage = loader.uiImage {
                    Button {
                        Task {
                            await saveImage()
                        }
                    } label: {
                        Label(String(localized: "Save Image"), systemImage: Icons.import)
                    }
                    
                    ShareLink(item: Image(uiImage: uiImage), preview: .init("photo", image: Image(uiImage: uiImage)))
                }
            }
    }
    
    func saveImage() async {
        do {
            let (data, _) = try await ImagePipeline.shared.data(for: .init(url: loader.url))
            let imageSaver = ImageSaver()
            try await imageSaver.writeToPhotoAlbum(imageData: data)
            ToastModel.main.add(.success("Image Saved"))
        } catch {
            ToastModel.main.add(.failure(
                "Failed to Save Image. You may need to allow Mlem to access your Photo Library in System Settings."
            ))
            print(String(describing: error))
        }
    }
}
