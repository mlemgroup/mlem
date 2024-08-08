//
//  SimpleAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import Nuke
import SwiftUI

struct SimpleAvatarView: View {
    @Environment(Palette.self) var palette

    @State private var uiImage: UIImage
    @State private var loading: Bool

    let url: URL?
    let type: AvatarType

    init(
        url: URL?,
        type: AvatarType
    ) {
        self.url = url
        self.type = type

        self._uiImage = .init(wrappedValue: .init())
        self._loading = .init(wrappedValue: url != nil)
    }

    var defaultImage: UIImage {
        .init(systemName: Icons.personCircle)!
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
            } else {
                Image(uiImage: uiImage)
                    .task(loadImage)
            }
        }
    }

    @Sendable
    func loadImage() async {
        guard let url else { return }

        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)

            let image = try await imageTask.image
            uiImage = image.circleMasked ?? image
            loading = false
        } catch {
            print(error)
        }
    }
}
