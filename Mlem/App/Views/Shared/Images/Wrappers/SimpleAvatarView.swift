//
//  SimpleAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import MlemMiddleware
import Nuke
import SwiftUI

struct SimpleAvatarView: View {
    @State private var uiImage: UIImage
    @State private var loading: Bool

    let url: URL?
    let type: MediaView.Fallback

    init(
        url: URL?,
        type: MediaView.Fallback
    ) {
        self.url = url
        self.type = type

        self._uiImage = .init(wrappedValue: .init())
        self._loading = .init(wrappedValue: url != nil)
    }

    var defaultImage: UIImage {
        guard let fromIcon: UIImage = .init(icon: type.icon) else {
            assertionFailure("Could not create default image from \(type.icon)")
            return .blank
        }
        return fromIcon
            .applyingSymbolConfiguration(.init(
                font: .systemFont(ofSize: 17),
                scale: .large
            ))!
            .withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    }

    var body: some View {
        Group {
            if url == nil {
                Image(uiImage: defaultImage)
                    .symbolVariant(.circle.fill)
            } else {
                Image(uiImage: uiImage)
                    .task { await loadImage() }
            }
        }
    }

    func loadImage() async {
        guard let url else { return }

        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)

            let image = try await imageTask.image
            uiImage = image.circleMasked
            loading = false
        } catch {
            handleError(error, silent: true)
        }
    }
}
