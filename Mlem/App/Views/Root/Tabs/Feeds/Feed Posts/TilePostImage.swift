//
//  TilePostImage.swift
//  Mlem
//
//  Created by Sjmarf on 28/05/2024.
//

import MlemMiddleware
import Nuke
import SwiftUI

struct TilePostImage: View {
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var dimension: CGFloat { UIScreen.main.bounds.width / 2 - (AppConstants.standardSpacing * 1.5) }
    
    @State var loading: Bool = false
    @State var uiImage: UIImage = .init()
    @Binding var color: Color
    
    var body: some View {
        switch post.postType {
        case .text, .titleOnly:
            Image(systemName: post.placeholderImageName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(palette.secondary)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .image(url):
            imageView(url: url)
        case let .link(url):
            if let url {
                imageView(url: url)
            }
        }
    }

    @ViewBuilder
    func imageView(url: URL) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .mask(LinearGradient(stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.5),
                .init(color: .clear, location: 0.7),
                .init(color: .clear, location: 1)
            ], startPoint: .top, endPoint: .bottom))
            .background(color)
            .frame(width: dimension, height: dimension)
            .task {
                await loadImage(url: url)
            }
    }
    
    func loadImage(url: URL) async {
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            let smallImageTask = ImagePipeline.shared.imageTask(
                with: url.appending(queryItems: [.init(name: "thumbnail", value: "32")])
            )
            async let uiImage = try await imageTask.image
            async let smallImage = try await smallImageTask.image
            color = try await .init(uiColor: smallImage.findAverageColor() ?? .clear)
            self.uiImage = try await uiImage
            loading = false
        } catch {
            print(error)
        }
    }
}
